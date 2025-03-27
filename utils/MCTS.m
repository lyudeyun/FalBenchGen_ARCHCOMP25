%%This class includes the main function of Monte-Carlo Tree Search. 
%
%The main function can be triggered in the last line of the constructor, so
%just instantiate this class if you want to run MCTS.
%
%

%%
classdef MCTS < handle
    properties
        Br %the Simulink model
        
        max_value %the largest (worst) robustness over all the nodes

        budget %an integer indicating how many times the high-level loop will be accessed
        scalar %a real number to balance the exploration and explanation
        
        phi % the STL formula
        T % the time bound of a simulation (not timeout)
        total_stage %the number of stages (= control points)
        
        solver % the hill-climbing optimization solver in MCTS
        time_out % the timeout for playout
        
		input_num
        %input_name %the name of the input signals
        input_range %the range of the input signal values
        div % how to discretize (partition) the input space
        
         
        child_num % the number of children
        falsified % a boolean indicating whether the falsification is successful
        
        root_node % the root node
         
        
        best_children_range % the sequence of sub-regions with the best robustness value
        
		simulations 
        
        x_log
        obj_log
		vars
		ranges
        
    end
    
   
 %%   
    methods
        
        %the constructor of MCTS
        function this = MCTS(br, budget, scalar, phi, T, ts, solver, time_out, input_num, input_range, div )
            this.max_value = 0;
            this.Br = br;
            this.budget = budget;
            this.scalar = scalar;
            
            this.phi = phi;
            this.T = T;
            this.total_stage = ts;
            
            this.solver = solver;
            this.time_out = time_out;
            
            this.input_num = input_num;
            this.input_range = input_range;
            this.div = div;
            
            signal_dimen = numel(div);
            
            unit = [];
            for u = 1:signal_dimen
                unit = [unit (input_range(u,2)-input_range(u,1))/div(u)];
            end
            
            while true
            
                children_list = [];
                i = ones(1,signal_dimen);
                k = 1;

                while true
                    region = [];
                    for j = 1:signal_dimen
                        region = [region; [input_range(j,1)+unit(j)*(i(j)-1) input_range(j,1)+unit(j)*i(j)]];
                    end
                    r = Region(region);
                    children_list = [children_list r];


                    break_f = 0;
                    while true
                        if i(k)+1 > div(k)
                            i(k) = 1;
                            if k+1 > signal_dimen
                                break_f = 1;
                                break;
                            else
                                k = k+1;
                            end
                        else
                            i(k) = i(k) + 1;
                            k = 1;
                            break;
                        end
                    end

                    if break_f == 1
                        break;
                    end
                end
            
            
            
                this.child_num = prod(div);
                this.simulations = 0;

                this.falsified = 0;
                this.best_children_range = [Region([])];

                root_state = myState(0,[], children_list, input_num, input_range,ts); %see the constructor of State
                this.root_node = MCTS_Node(root_state, NaN, this.child_num);
                %this.log = [];
                this.x_log = [];
                this.obj_log = [];
            
            
                
                this.uctsearch(this.root_node);
                break;
                %{
                if f == 0
                    % continue;
                    break;
                else
                    % break;
                    continue;
                end
                %}
				%bbr = br.copy();
				%input_gen.type = 'UniStep';
				%input_gen.cp = cp;
				%bbr.SetInputGen(input_gen);
				%dim = numel(input_name);
				%for i = 1:ts
			%		for j = 1:dim
			%			bbr.SetParamRanges({strcat(input_name(j),'_u',num2str(i-1))}, input_range(j, :));
			%		end
		%		end
				%this.vars = bbr.GetSysVariables();
				%this.ranges = bbr.GetParamRanges(vars);
            end
        end
        
        
        %%
        % the whole process of MCTS, including tree_policy, default_policy
        % and backup
        % input: root node
     
        function uctsearch(this, node)
            
            %for k = 1:this.budget
            % flag = 1;
            while true
                front = this.tree_policy(node);
                [reward, sim, plog] = this.default_policy(front);
                
                if reward > this.max_value
                    this.max_value = reward;
                end
                this.x_log = [this.x_log plog.X_log];
                this.obj_log = [this.obj_log plog.obj_log];
                
                    
                if reward < 0
                    this.falsified = 1;
                    this.backup(front,reward, sim);
                    % flag = 0; %falsified, so it needs redoing
                    break;
                end
                this.backup(front, reward, sim);
                disp([newline num2str(numel(this.obj_log))]);
                if numel(this.obj_log) > this.budget
                    break;
                end
                
                %this.plottree(); %for debugging
                %pause(1); 
            end
            
        end
        %%
        
        %tree_policy: the policy to pick a node.
        %either expand a new node or pick a best child according to UCB1
        %input: root node
        %output: the picked node
        function front = tree_policy(this, node)
            while node.state.terminal() == false
                
                if node.fully_expanded() == false
                    front = this.expand(node);
                    return;
                else
                    node = this.best_child(node);
                    
                end
            end
            front = node;
        end
        %%
        %auxiliary function for tree_policy to expand a new child
        %input: a node
        %output: the new generated child
        function child = expand(this,node)
            
            s = node.state.next_state_tp();
            child = MCTS_Node(s, node, this.child_num);
            node.add_child(child);
        end
        
        %%
        %auxiliary function for tree_policy to pick a best child
        %this function is based on UCB1
        %input: a node
        %output: the best child of the node according to UCB1
        function child = best_child(this,node)
            best_score = -1;
            best_children = [];
            for c = node.children
                exploitation = 1.0-(c.reward/(this.max_value));
                exploration = sqrt((2.0*log(node.visit))/c.visit);
                score = exploitation+ this.scalar*exploration;
                if score == best_score
                    best_children = [best_children c];
                end
                if score > best_score
                    best_children = c;
                    best_score = score;
                end
            end
            
            n = numel(best_children);
            if n>1
                child = best_children(randi(n));
            else
                child = best_children(1);
            end
            
        end
        %%
        %default_policy: how to compute a reward for a node
        %input: a node
        %output: the reward of this node
        function [reward, sim, log] = default_policy(this,node)
            
            state = node.state;
            while state.terminal() == false
                state = state.next_state_dp();
            end
            [reward, sim, log] = state.reward(this.Br, this.T, this.phi, this.solver, this.time_out);
            
        end
        
        
        %%
        % backup: trace back from the leaf to the root, and update the
        % visit times and
        % robustness with the newly computed one if it is better than the
        % existent ones. 
        % also update the best_children_range if needed
        function backup(this, node, reward, sim)
            
            if reward < this.root_node.reward
                this.best_children_range = node.state.input_region;
            end
			this.simulations = this.simulations + sim;
            
            while true
                node.visit = node.visit+1;
               
                
                if reward < node.reward
                    node.reward = reward;
                end
                
                
                if node.state.stage == 0
                    break;
                else
                    node = node.parent;
                end
            end
        end
        %%
        % this function is called when activating the calling in uctsearch,
        % this function is used for debugging, to see the shape of the
        % tree.
        function plottree(this)
            queue = CQueue();
            queue.push(this.root_node);
            nodes = [0];
            node_id = 1;
            str = [];
            while ~queue.isempty()
                curr = queue.pop();
                %curr.state.stage
                if curr.state.stage == 0
                    mat = 'NaN';
                else
                    %curr.state.input_region(curr.state.stage).signal_region
                    mat = mat2str(curr.state.input_region(curr.state.stage).signal_region);
                end
                curr_str = convertCharsToStrings(strcat('v:', num2str(curr.visit),' r:',num2str(curr.reward), mat));
                str = [str;curr_str];
                
                for c = curr.children
                    queue.push(c);
                    nodes = [nodes node_id];
                end
                node_id = node_id + 1;
                
            end
            
            
            my_treeplot(nodes);
            
            [x,y] = my_treelayout(nodes);
            x = x';
            y = y';

            name1 = str;

            text(x(:,1), y(:,1), name1, 'VerticalAlignment','bottom','HorizontalAlignment','right')
        end
        
    end
    
end
