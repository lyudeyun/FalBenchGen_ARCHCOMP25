classdef traces_signal_gen < signal_gen
    % Wrapper class for F16

    properties
        inputNum;
        outputNum;
        net;
        T;
        cp;
    end

    methods

        function this = traces_signal_gen(inputNum, outputNum, net, T)
            
            % 4 refers to 4 control points
            this.p0 = zeros(4*inputNum, 1);
            this.inputNum = inputNum;
            this.outputNum = outputNum;
            this.net = net.net;
            this.T = T;
            this.cp = T/6;
            
            for i = 1:inputNum
                for j = 1:this.cp
                    paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
                    this.params{1,this.cp*(i-1)+j} = paramName;
                    this.p0(i*j) = 0;
                end
            end

            if outputNum == 1
                this.signals = {'b'};
            else
                this.signals = {};
                for i = 1:outputNum
                    signalName = strcat('b', num2str(i));
                    this.signals{i} = signalName;
                end
            end
        end

        %%
        function X = computeSignals(this, p, t_vec) %#ok<*MANU,*INUSD>

            %% Input X and to predict Y
            
            for i = 1:this.inputNum
                for j = 1:this.cp
                    U_name = sprintf('u%d_%d', i-1, j-1);
                    eval([U_name '=' num2str(p(i*j)) ';']);
                end
            end

            inputSignals = [];
            for i = 1:this.inputNum
                curInputSignal = [];
                for j = 1:this.cp
                    if j < this.cp
                        curInputSignal = [curInputSignal, ones(1,6)*p(i*j)];
                    elseif j == this.cp
                        curInputSignal = [curInputSignal, ones(1,7)*p(i*j)];
                    end
                end
                inputSignals = [inputSignals; curInputSignal];
            end

            YPred = predict(this.net,inputSignals,'MiniBatchSize',1);

            X = YPred;
        end

    end

end