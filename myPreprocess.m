function Data = myPreprocess(fileToRead,Flag_Single)
SID_Digits = 4; % Define the number of EPC
newData = importdata(fileToRead);
Temperature = newData.('data');
textdata = newData.('textdata');
clear newData

function value = str2int2(str2) 
	value = (str2(1)-'0')*10+str2(2)-'0';
end

function value = str2int4(str4) 
	value = (str4(1)-'0')*1000+(str4(2)-'0')*100+(str4(3)-'0')*10+str4(4)-'0';
end

function value = str2int(str)
    switch length(str)
        case 1
            value = str-'0';
        case 2
            value = (str(1)-'0')*10+str(2)-'0';
    end
end

num  = length(Temperature);
Day  = zeros(num,1);
Hour = zeros(num,1);
Min  = zeros(num,1);
Sec  = zeros(num,1);
EPC  = zeros(num,1);
AntNum = zeros(num,1);
RSSI = zeros(num,1);

if Flag_Single == 1
    Importing_Waiting = waitbar(0,'Importing Data'); %  Initialize the interface of waiting bar
    pause(0.5);
end

radio = 0.1;

for k = 1:num
    temp = textdata{k+1,1};
    Day(k) = str2int2(temp(10:11));
    Hour(k) = str2int2(temp(13:14));
    Min(k) = str2int2(temp(16:17));
    Sec(k) = str2int2(temp(19:20));
    EPC(k) = str2int4(textdata{k+1,2}(end-SID_Digits+1:end));
    AntNum(k) = textdata{k+1,3}-'0';
    RSSI(k) = str2int(textdata{k+1,4});
    if Flag_Single == 1
        if k > radio*num
            waitbar(radio,Importing_Waiting,[num2str(radio*100) '%' ' Completed']); 
            radio = radio+0.1;
        end    
    end
end	
if Flag_Single == 1
    close(Importing_Waiting)
end
% if length(Months) == 2
%     Mon  = zeros(num,1);
%     Days = [31 28 31 30 31 30 31 31 30 31 30 31];
%     for k = 1:num
%         Mon(k) = str2int2(textdata{k+1,1}(7:8));
%     end
%     Index = Mon(:,1) == Months(2);
%     Day(Index) = Day(Index)+Days(Months(1));
% end

Time = Day*24 + Hour + Min/60 + Sec/3600;
Data = [Time EPC AntNum RSSI Temperature];
end