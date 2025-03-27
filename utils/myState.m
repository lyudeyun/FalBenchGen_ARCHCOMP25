%% 
% This class is the content of each node.
% Each state corresponds to a node.
%
classdef myState<handle
   properties
       
       input_region % a list of sub-regions represented by the nodes from 
                    % the root to the current node
                    
       stage % the stage of the current node
       
       total_children_list % a static list, including all the children of 
                           % the node, each child corresponds to a
                           % sub-region
       children_list  % the set of unexpanded children
       
	   input_num
       %input_name % the name of input siganl, same to the property in MCTS
       input_range % input signal value's range, same to the property in MCTS
       signal_dimen % the dimension of the input signal
       total_stage %the number of stages, a static integer
   end
   %%
   % the constructor

   methods
       function this = myState(st, ir, cl, in, inrange, ts)
           
           this.stage = st;
           this.input_region = ir;
           
           this.total_children_list = cl;
           this.children_list = cl;
           
		   this.input_num = in;
           %this.input_name = in;
           this.input_range = inrange;
           this.signal_dimen = numel(in);
           this.total_stage = ts;
       end
       
       
       %%
       % generate a new node (state) for tree_policy
       % output: a new state
       function next = next_state_tp(this)
           st = this.stage + 1;
           
           i = randi(numel(this.children_list));
           
           reg = this.children_list(i);
          
           ir = [this.input_region reg];
           this.children_list(i) = [];
           next = myState(st, ir,this.total_children_list, this.input_num, this.input_range,  this.total_stage);
       end
       %%
       % generate a new node (state) for default_policy
       % output: a new state
       function next = next_state_dp(this)
           st = this.stage + 1;
           
           ir = [this.input_region this.input_range];
           next = myState(st, ir,this.total_children_list, this.input_num, this.input_range, this.total_stage);
       end
       
       %%
       % this function is to do the playout, and compute a reward by
       % hill-climbing. this function just follows a regular way to call
       % Breach.
       %
       function [r,n, l] = reward(this, br, T, phi, solver, time_out)
           %br.Sys.tspan = 0:.01:T;
           %input_gen.type = 'UniStep';
           %input_gen.cp = this.total_stage;
           %br.SetInputGen(input_gen);
           
           %for i = 1:this.total_stage
           %    for j = 1:numel(this.input_name)
           %        br.SetParamRanges({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_region(i).get_signal(j));%to do
           %        br.SetParam({strcat(this.input_name(j),'_u',num2str(i-1))}, this.input_region(i).center(j))
           %    end
           %end

		   B = BreachSignalGen(br);
		   B.SetTime(0:1:T);
		   for i = 1: this.total_stage
			   for j = 1: this.input_num
				   B.SetParamRanges({strcat('u', num2str(j-1), '_', num2str(i-1))}, this.input_region(i).get_signal(j)); %to do
				   B.SetParam({strcat('u', num2str(j-1), '_', num2str(i-1))}, this.input_region(i).center(j));
			   end
		   end
		   
           falsif_pb = FalsificationProblem(B, phi);
           falsif_pb.setup_solver(solver);
           falsif_pb.max_obj_eval = time_out;
           falsif_pb.solve();

           n = falsif_pb.nb_obj_eval; 
           r = falsif_pb.obj_best;
           l = [];
           l.X_log = falsif_pb.X_log;
           l.obj_log = falsif_pb.obj_log;
           
       end

       %%
       % to judge whether the default has reached the leaf.
       % output: a boolean indicating whether the leaf has reached.
       function stop = terminal(this)
           stop = false;
           if this.stage == this.total_stage
               stop = true;
           end
       end
   end
end
