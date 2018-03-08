function varargout = GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in importButton.
function importButton_Callback(hObject, eventdata, handles)
% hObject    handle to importButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.popupmenu1,'String','');
set(handles.popupmenu2,'String','');
set(handles.Edit_AnNum,'String','');
set(handles.Edit_SenNum,'String','');
set(handles.Edit_Row,'String','');
set(handles.Edit_Column,'String','');

[FileName,PathName,FilterIndex] =  uigetfile({'*.csv';'*.*'},...
    'Select files to import','MultiSelect','on');


if ischar(FileName) % Single file to be imported
    Data = myPreprocess([PathName FileName],1);
else % Multi files to be imported
    Importing_Waiting = waitbar(0,'Importing Data ...'); % Initialize the interface of waiting bar
    pause(0.5);
    Data = myPreprocess([PathName FileName{1}],0);
    waitbar(1/length(FileName),Importing_Waiting,[num2str(1/length(FileName)*100) '%' ' Completed']); 
    for i = 2:length(FileName)
        Data = [Data; myPreprocess([PathName FileName{i}],0)];
        waitbar(i/length(FileName),Importing_Waiting,[num2str(i/length(FileName)*100) '%' ' Completed']); 
    end
    close(Importing_Waiting);
end
Data(:,1) = Data(:,1)-min(Data(:,1));
maxTime = max(Data(:,1));
SID = unique(Data(:,2));    % Sensor ID
strSID = num2str(SID);      % Transform Sensor ID into string format
AID = unique(Data(:,3));    % Antanna ID
strAID = num2str(AID);      % Transform Antenna ID into string format
SensN = length(SID);        % The number of sensors
AntN  = length(AID);        % The number of Antanna

set(handles.Edit_AnNum,'String',num2str(AntN));
set(handles.Edit_SenNum,'String',num2str(SensN));


Importing_Done = msgbox('Importing Done£¡','Reminder','help','modal');

strAID_new = '';
for i = 1:AntN
    strAID_new = [strAID_new,strAID(i,:),'|'];
end
set(handles.popupmenu1,'String',['All|',strAID_new]);

strSID_new = '';
for i = 1:SensN
    strSID_new = [strSID_new,strSID(i,:),'|'];
end
set(handles.popupmenu2,'String',['All |',strSID_new]);

handles.Data = Data;
handles.PathName = PathName;
guidata(hObject,handles);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data = handles.Data;
PathName = handles.PathName;

list1 = get(handles.popupmenu1,'String');
val1 = get(handles.popupmenu1,'Value');
Ant_Selected = list1(val1,:);

list2 = get(handles.popupmenu2,'String');
val2 = get(handles.popupmenu2,'Value');
Sens_Selected = list2(val2,:);

minTemp = str2double(get(handles.minTemp,'String'));
maxTemp = str2double(get(handles.maxTemp,'String'));

strRow = get(handles.Edit_Row,'String');
strCol = get(handles.Edit_Column,'String');
row = str2double(strRow);    
col = str2double(strCol); 

SID = unique(Data(:,2));%Sensor ID
SensN = length(SID);	%The total number of sensors



if (strcmp(Sens_Selected,'All '))
    
    if (isempty(strRow) || isempty(strCol))
        h=msgbox('Please select right row and column!','Reminder','help','modal');
    end
    if row*col<2*SensN
        h=msgbox('Not enough row or column£¡','Reminder','help','modal');
    end

    if (~isempty(strRow) && ~isempty(strCol) && (row*col>=2*SensN))
        singlePlot(Data,PathName,Ant_Selected,Sens_Selected,minTemp,maxTemp,row,col);
        h=msgbox('Ploting Done£¡','Reminder','help','modal');
    end
else
    singlePlot(Data,PathName,Ant_Selected,Sens_Selected,minTemp,maxTemp,row,col);
    h=msgbox('Ploting Done£¡','Reminder','help','modal');
end














function minTemp_Callback(hObject, eventdata, handles)
% hObject    handle to minTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minTemp as text
%        str2double(get(hObject,'String')) returns contents of minTemp as a double


% --- Executes during object creation, after setting all properties.
function minTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxTemp_Callback(hObject, eventdata, handles)
% hObject    handle to maxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxTemp as text
%        str2double(get(hObject,'String')) returns contents of maxTemp as a double


% --- Executes during object creation, after setting all properties.
function maxTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Row_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Row as text
%        str2double(get(hObject,'String')) returns contents of Edit_Row as a double


% --- Executes during object creation, after setting all properties.
function Edit_Row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Column_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Column as text
%        str2double(get(hObject,'String')) returns contents of Edit_Column as a double


% --- Executes during object creation, after setting all properties.
function Edit_Column_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_AnNum_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_AnNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_AnNum as text
%        str2double(get(hObject,'String')) returns contents of Edit_AnNum as a double


% --- Executes during object creation, after setting all properties.
function Edit_AnNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_AnNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_SenNum_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_SenNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_SenNum as text
%        str2double(get(hObject,'String')) returns contents of Edit_SenNum as a double


% --- Executes during object creation, after setting all properties.
function Edit_SenNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_SenNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
