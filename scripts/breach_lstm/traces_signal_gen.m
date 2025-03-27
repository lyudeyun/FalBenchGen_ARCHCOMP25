classdef traces_signal_gen < signal_gen
    % Wrapper class for F16

    properties
        inputNum;
        outputnum;
        net;
        T;
        T2;
    end

    methods

        function this = traces_signal_gen(inputNum, outputNum, net, T)

            % 范例
            % inputnum = 2;
            % outputnum = 1;
            % Totaltime = 30;
            % this.params = {'u0_0','u0_1','u0_2','u0_3'};
            % this.p0 = [0;0;0;0];
            % this.signals = {'b'};

            this.p0 = zeros(4*inputNum, 1);
            this.inputNum = inputNum;
            this.outputnum = outputNum;
            this.net = net.net;
            this.T = T+1;
            this.T2 = round(this.T/6);
            %
            for i = 1:inputNum
                % params = {};
                % p0 = [];
                for j = 1:this.T2
                    paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
                    this.params{1,this.T2*(i-1)+j} = paramName;
                    % params{j} = paramName;
                    this.p0(i*j) = 0;
                    % p0{j} = 0;
                end
                % this.params = horzcat(this.params, params);
                % this.p0 = [this.p0; transpose(p0)];
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
            %}



        end

        %%
        function X = computeSignals(this, p, t_vec) %#ok<*MANU,*INUSD>

            %% Input X and to predict Y
            % for i = 1:inputnumx4
            %{
            u0_0 = p(1);
            u0_1 = p(2);           
            u0_2 = p(3);        
            u0_3 = p(4);
            %}
            %
            for i = 1:this.inputNum
                for j = 1:this.T2
                    U_name = sprintf('u%d_%d', i-1, j-1);
                    eval([U_name '=' num2str(p(i*j)) ';']);
                    % this.params{i,j} = p(j*i);
                end
            end
            %}

            % XTest = [ones(1,6)*u0_0, ones(1,6)*u0_1, ones(1,6)*u0_2, ones(1,6)*u0_3];
            %
            XTest = [];
            for i = 1:this.inputNum
                XTest_row = [];
                for j = 1:this.T2
                    XTest_row = [XTest_row, ones(1,6)*p(i*j)];
                end
                XTest = [XTest; XTest_row];
            end
            %}

            % fprintf(XTest);

            YPred = predict(this.net,XTest,'MiniBatchSize',1);

            X = YPred;
            % X = zeros(1,24);

        end

    end

end