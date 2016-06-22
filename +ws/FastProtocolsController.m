classdef FastProtocolsController < ws.Controller
    
    methods
        function self = FastProtocolsController(wavesurferController,wavesurferModel)
%             self = self@ws.Controller(wavesurferController, wavesurferModel, {'fastProtocolsFigureWrapper'});
            
            % Call the superclass constructor
            self = self@ws.Controller(wavesurferController,wavesurferModel); 

            % Create the figure, store a pointer to it
            fig = ws.FastProtocolsFigure(wavesurferModel,self) ;
            self.Figure_ = fig ;
        end  % function        
    end  % public methods block

    methods
        function ClearRowButtonActuated(self, varargin)
            selectedIndex = self.Model.IndexOfSelectedFastProtocol;
            if isempty(selectedIndex) ,
                return
            end
            theFastProtocol = self.Model.FastProtocols{selectedIndex} ;
            theFastProtocol.ProtocolFileName = '';
            theFastProtocol.AutoStartType = 'do_nothing';
        end  % function
        
        function SelectFileButtonActuated(self, varargin)
            selectedIndex = self.Model.IndexOfSelectedFastProtocol;
            if isempty(selectedIndex) ,
                return
            end
            
            % By default start in the location of the current file.  If it is empty it will
            % just start in the current directory.
            startLocationLoadedFromPreferences = ws.Preferences.sharedPreferences().loadPref('LastProtocolFilePath') ;
            
            actualStartLocation = self.Model.FastProtocols{selectedIndex}.ProtocolFileName;
            if isempty(actualStartLocation)
                if ~exist('startLocationLoadedFromPreferences','var') ,
                    actualStartLocation='';
                else
                    actualStartLocation =  startLocationLoadedFromPreferences;
                end
            end
            fprintf('originalFileName: %s \n',actualStartLocation);
            [filename, dirName] = uigetfile({'*.cfg'}, 'Select a Protocol File', actualStartLocation);
            
            % If the user cancels, just exit.
            if filename == 0 ,
                return
            end
            
            newFileName=fullfile(dirName, filename);
            theFastProtocol=self.Model.FastProtocols{selectedIndex};
            ws.Controller.setWithBenefits(theFastProtocol,'ProtocolFileName',newFileName);
            if canonicalizePath(startLocationLoadedFromPreferences) ~= canonicalizePath(actualStartLocation)
                ws.Preferences.sharedPreferences().savePref('LastProtocolFilePath', actualStartLocation);
            end
        end  % function
        
        function TableCellSelected(self,source,event) %#ok<INUSL>
            indices=event.Indices;
            if isempty(indices), return, end
            rowIndex=indices(1);
            %columnIndex=indices(2);
            self.Model.IndexOfSelectedFastProtocol=rowIndex;
        end
    
        function TableCellEdited(self,source,event) %#ok<INUSL>
            indices=event.Indices;
            newString=event.EditData;
            rowIndex=indices(1);
            columnIndex=indices(2);
            fastProtocolIndex=rowIndex;
            if (columnIndex==1) ,
                % this is the Protocol File column
                if isempty(newString) || exist(newString,'file') ,
                    theFastProtocol=self.Model.FastProtocols{fastProtocolIndex};
                    ws.Controller.setWithBenefits(theFastProtocol,'ProtocolFileName',newString);
                end
            elseif (columnIndex==2) ,
                % this is the Action column
                newValue=ws.startTypeFromTitleString(newString);  
                % newValue=ws.fastprotocol.StartType.str2num(newString);
                theFastProtocol=self.Model.FastProtocols{fastProtocolIndex};
                ws.Controller.setWithBenefits(theFastProtocol,'AutoStartType',newValue);
            end            
        end  % function        
    end  %methods block
    
    methods (Access=protected)
%         function shouldStayPut = shouldWindowStayPutQ(self, varargin)
%             % This method is inhierited from AbstractController, and is
%             % called after the user indicates she wants to close the
%             % window.  Returns true if the window should _not_ close, false
%             % if it should go ahead and close.
%             shouldStayPut=false;
%             
%             % If acquisition is happening, ignore the close window request
%             wavesurferModel=self.Model;
%             if isempty(wavesurferModel) || ~isvalid(wavesurferModel) ,
%                 return
%             end            
%             isIdle=isequal(wavesurferModel.State,'idle')||isequal(wavesurferModel.State,'no_device');
%             if ~isIdle ,
%                 shouldStayPut=true;
%             end
%         end  % function
    end % protected methods block    
    
    properties (SetAccess=protected)
       propBindings = struct(); 
    end
    
end  % classdef
