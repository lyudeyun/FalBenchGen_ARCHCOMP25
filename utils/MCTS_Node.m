classdef MCTS_Node < handle
    properties
        visit
        
        reward
        state
        
        children
        parent
        
        max_child_num
    end
    
    
    
    methods
        function this = MCTS_Node(state, parent, child_num)
            this.visit = 0;
            this.reward = intmax;
            this.state = state;
            this.children = [];
            this.parent = parent;
            this.max_child_num = child_num;
        end
        
        function add_child(this, child)
            
            this.children = [this.children child];
        end
        
        function update(this, reward)
            this.reward = this.reward + reward;
            this.visit = this.visit + 1;
        end
        
        function full = fully_expanded(this)
            full = false;
            if numel(this.children) == this.max_child_num
                full = true;
            end
        end
    end
end