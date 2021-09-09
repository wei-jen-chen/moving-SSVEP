%3-5 min
%% 
%clear
sca;
close all;
clearvars;
%% 
%event setting
config_io;
add=['CFF8'];
address = hex2dec([add])

%% 
%default settings for Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = max(screens);
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

Screen('TextSize',window, 80);
DrawFormattedText(window, 'Any key to continue', 'center', 'center', white);
Screen('Flip', window);
% Wait for a key press
KbStrokeWait;
% hide the mouse
HideCursor;
%% 
Screen('TextSize',window, 80);DrawFormattedText(window, 'ready', 'center', 'center', white);
Screen('Flip', window);
pause(1);
Screen('TextSize',window, 80);DrawFormattedText(window, 'go', 'center', 'center', white);
Screen('Flip', window);
pause(1);

%event1:start
event(address,1);
%% 
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 300 by 300 pixels
baseRect = [0 0 300 300];

rectColorB = [0 0 0];
rectColorW = [1 1 1];

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;
% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
%% 
for loop_i=1:10
    %initialize
    screenWidthD2 = screenXpixels*0.5;
    screenWidthD4 = screenXpixels*0.25;
    freq = [6 11 21];
    flashtime = 0;
    flashnext = 0;
    freq_i = 1;
    % the number of white in each flash
    white_num = 60/freq(freq_i)/2;
    %time initialize
    time = 0;
    %event initialize
    event_first=1;
    moving_event_first=0;
   
    % Loop the animation until a key is pressed
    while ~KbCheck && freq_i<4
        % Position of the square on this frame
        if time<2
            moving_event_first=1;
            xpos = 0;
            %event flag
            if event_first==1 && freq_i==1
                %event2:non moving SSVEP freq1
                event(address,2);
                event_first=0;
            elseif event_first==1 && freq_i==2
                %event4:non moving SSVEP freq2
                event(address,4);            
                event_first=0;
            elseif event_first==1 && freq_i==3
                %event6:non moving SSVEP freq3
                event(address,6);
                event_first=0;
            end
        else
            if moving_event_first==1
                event_first=1;
                moving_event_first=0;
            end
            xpos = screenWidthD4*mod(time-2,4);
            %event flag
            if event_first==1 && freq_i==1
                %event3:moving SSVEP freq1
                event(address,3);
                event_first=0;
            elseif event_first==1 && freq_i==2
                %event5:moving SSVEP freq2
                event(address,5);            
                event_first=0;
            elseif event_first==1 && freq_i==3
                %event7:moving SSVEP freq3
                event(address,7);
                event_first=0;
            end
        end

        % Add this position to the screen center coordinate. This is the point
        % we want our square to oscillate around
        if time<2
            squareXpos = xCenter-screenWidthD2+150;
        else
            squareXpos = xCenter-screenWidthD2+150+xpos;
        end

        % Center the rectangle on the centre of the screen
        centeredRect = CenterRectOnPointd(baseRect, squareXpos, yCenter);

        % Draw the rect to the screen
        if flashnext==1 && white_num>0
            Screen('FillRect', window, rectColorW,centeredRect);
            white_num = white_num-1;
        else
            Screen('FillRect', window, rectColorB,centeredRect);
            flashnext = 0;
            if freq_i<4
                white_num = 60/freq(freq_i)/2;
            end
        end

        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % Increment the time
        time = time+ifi;
        %decide next loop change center color or not
        flashtime = flashtime+ifi;
        if freq_i<4 && flashtime>1/freq(freq_i)
            flashnext = 1;
            flashtime = 0;
        end

        if time>6
            %reset event_flag
            event_first=1;
            freq_i = freq_i+1;
            flashnext = 0;

            %update the white_num for next freq
            if freq_i<4
                white_num = 60/freq(freq_i)/2;
            end

            %print a cross in 1 second            
            % Set up alpha-blending for smooth (anti-aliased) lines
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            % Here we set the size of the arms of our fixation cross
            fixCrossDimPix = 40;
            % Now we set the coordinates (these are all relative to zero we will let
            % the drawing routine center the cross in the center of our monitor for us)
            xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
            yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
            allCoords = [xCoords; yCoords];
            % Set the line width for our fixation cross
            lineWidthPix = 8;
            % Draw the fixation cross in white, set it to the center of our screen and
            % set good quality antialiasing
            Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
            % Flip to the screen
            Screen('Flip', window);

            pause(1);
            time = 0;

        end
    end
end
%event8:end
event(address,8);
%% 
% Clear the screen
sca;
