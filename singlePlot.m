function singlePlot(Data,PathName,Ant_Selected,Sens_Selected,minTemp,maxTemp,row,col)

%color = ['r';'g';'b';'c';'m';'y';'k'];
% Plotting_Waiting = waitbar(0,'Plotting ...'); % Waiting bar initial interface
% pause(0.5);
minRSSI = 0;
maxRSSI = 40;
maxSensNum = 20;

color = [[1 0 0];[0 1 0];[0 0 1];[1 1 0];[1 0 1];[0 1 1];...
    [0 0.79 0.34];[0.16 0.14 0.13];[0.18 0.55 0.34];[0.22 0.37 0.06];...
    [0.24 0.35 0.67];[0.5 0.16 0.16];[0.53 0.81 0.92];[0.54 0.17 0.89];...
    [0.61 0.4 0.12];[0.64 0.58 0.5];[0.74 0.99 0.79];[0.94 0.9 0.55];[1 0.27 0]];


maxTime = max(Data(:,1));
SID = unique(Data(:,2));%Sensor ID
strSID = num2str(SID);	%Transfor SID into string
AID = unique(Data(:,3));%Antanna ID
SensN = length(SID);	%The total number of sensors
if SensN > maxSensNum
    display(SID);
	error('The number of sensors exceeds the number of predefined colors');
end

AntN  = length(AID);	%The total number of antenna

mark = false(SensN,AntN);%To mark non-null data

if ((not(strcmp(Ant_Selected,'All'))) || (not(strcmp(Sens_Selected,'All '))))   
    if strcmp(Ant_Selected,'All')
        SensN=1; 
    else
        if strcmp(Sens_Selected,'All ')
            AntN=1; 
        else
            SensN=1; 
            AntN=1; 
        end
    end
end

for i=1:AntN
    for j=1:SensN
        if ((strcmp(Ant_Selected,'All')) && (strcmp(Sens_Selected,'All ')))
            CurrData = Data( Data(:,3)==AID(i) & Data(:,2)==SID(j),:);    
        else
            if (strcmp(Ant_Selected,'All'))
                CurrData = Data( Data(:,3)==AID(i) & Data(:,2)==str2num(Sens_Selected),:); 
            else
                if (strcmp(Sens_Selected,'All '))
                    CurrData = Data( Data(:,3)==str2num(Ant_Selected) & Data(:,2)==SID(j),:); 
                else
                    CurrData = Data( Data(:,3)==str2num(Ant_Selected) & Data(:,2)==str2num(Sens_Selected),:);
                end
            end
        end
                  
        % Selcect data satisfying AntNum=AID(i) and EPC=SID(j)
        
       if ~isempty(CurrData)
 			mark(j,i) = true;
            % Delete the data out of the region
            CurrData( CurrData(:,5)<minTemp | CurrData(:,5)>maxTemp ,:)=[];
            % Moving average filler
            CurrData(:,5) = smooth(CurrData(:,5),20,'lowess');
            
            
            if (strcmp(Sens_Selected,'All '))
                g = figure(AntN*SensN*2+1+i);
                set(g,'NumberTitle','off',...
				'Name',['Ant' '0'+AID(i) '- All Sensors']);
            
                
                subplot(row,col,floor((j-1)/col)*col+j);
                plot(CurrData(:,1),CurrData(:,5),'*','MarkerSize',2);
                xlim([0 maxTime])
                ylim([minTemp maxTemp])
                title(['Ant' num2str(AID(i)) '-' num2str(SID(j))]);
                xlabel('Time/h');
                ylabel('Temperature/^oC');

                subplot(row,col,floor((j-1)/col)*col+j+col);
                plot(CurrData(:,1),CurrData(:,4),'*','MarkerSize',2);
                xlim([0 maxTime])
                ylim([minRSSI maxRSSI])
                title(['Ant' '0'+AID(i) '-' strSID(j,:)]);
                xlabel('Time/h');
                ylabel('RSSI/dB');                
            end
            
			h = figure((i-1)*SensN+j);
% 			set(h,'NumberTitle','off',...
% 				'Name',['Ant' '0'+AID(i) '-' num2str(SID(j))]);
			% Plot temperature by time
			subplot(2,1,1);
			plot(CurrData(:,1),CurrData(:,5),'*','MarkerSize',2);
			xlim([0 maxTime]);
			ylim([minTemp maxTemp]);
 			xlabel('Time/h');
			ylabel('Temperature/^oC');
            title(['Ant' num2str(AID(i)) '-' num2str(SID(j))]);
			
			% Plot RSSI by time
			subplot(2,1,2);
			plot(CurrData(:,1),CurrData(:,4),'*','MarkerSize',2);
			xlim([0 maxTime]);
			ylim([minRSSI maxRSSI]);
			xlabel('Time/h');
			ylabel('RSSI/dB');
            
            saveas(h,[PathName 'Ant' num2str(AID(i)) '-' num2str(SID(j)) '.jpg']);% Save figures
            close(h);
                                  
            if ((strcmp(Ant_Selected,'All')) || (strcmp(Sens_Selected,'All ')))
                % Plot temperature of total sensors
                f = figure(AntN*SensN*2+1);
                set(f,'NumberTitle','off','Name','All');
                subplot(AntN,1,i);
                plot(CurrData(:,1),CurrData(:,5),'*','MarkerSize',2,'color',color(j,:));
                hold on
            end
        end
%         waitbar(j/AntN/SensN,Plotting_Waiting,[num2str(j/AntN/SensN*100) '%' ' Completed']); 
    end
    if (strcmp(Sens_Selected,'All '))
        g = figure(AntN*SensN*2+1+i);
        set(g,'outerposition',get(0,'screensize'));
        saveas(g,[PathName 'All Sensors (Seperated) Ant' num2str(AID(i)) '.jpg']);
        close(g);
    end
    if ((strcmp(Ant_Selected,'All')) || (strcmp(Sens_Selected,'All ')))
        figure(AntN*SensN*2+1);
        subplot(AntN,1,i);
        xlim([0 maxTime]);
        ylim([minTemp maxTemp]);
        xlabel('Time/h');
        ylabel('Temperature/^oC');
        title(['Ant' num2str(AID(i))]);
        legend(strSID(mark(:,i),:));
    end
end
if ((strcmp(Ant_Selected,'All')) || (strcmp(Sens_Selected,'All ')))
    f = figure(AntN*SensN*2+1);
    set(f,'outerposition',get(0,'screensize'));
    saveas(f,[PathName 'All Sensors (Integrated).jpg']);
    close(f);
end

% close(Plotting_Waiting);

