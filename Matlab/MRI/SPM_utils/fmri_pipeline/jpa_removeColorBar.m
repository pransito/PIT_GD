function jpa_removeColorBar(path,bgcolor,position)
% routine that runs through Picture and removes additional ColorBar(s)
% path = complete Path with filname to image
% backgroundcolor of the Image in format 'R,G,B,'
% Position of ColorBar to Remove i.e. '0.93,0.1,0.95,0.9' which symolises
% (left, top , right, botton)

%% Initialize

% get Position of ColorBar
pos =textscan(position,'%s','Delimiter',',');
left = str2double(pos{1}{1});
top = str2double(pos{1}{2});
right = str2double(pos{1}{3});
botton = str2double(pos{1}{4});

% get RGB from Backgroundcolor
rgb =textscan(bgcolor,'%s','Delimiter',',');
bgcolorRed =  str2double(rgb{1}{1});
bgcolorGreen =  str2double(rgb{1}{2});
bgcolorBlue =  str2double(rgb{1}{3});

% check where the long side of the bar is located:     '0.1,0.9,0.12,0.1'
if (abs(right - left)) > (abs(botton - top))
    barPos{1} = 'wide';
    if top > 0.5
        barPos{2} = 'top';
    else
        barPos{2} = 'botton';
    end
else
    barPos{1} = 'heigh';
    if left > 0.5
        barPos{2} = 'right';
    else
        barPos{2} = 'left';
    end
end

% load Picture
try
    A = imread(path);
catch ME %please! otherwise i fall...
    disp('Could not load Image!');
    disp(ME.identifier);
end
% get Width and Height of the Picture
% h = heigh, w = width ,c(1) = red, c(2) = green, c(3)= blue
[h w c] = size(A);
% calculate the Pixels where the color-Bar is located
startPixelTop = ceil(h * top);
startPixelBotton = floor(h * botton);
startPixelRight = ceil(w * left);
startPixelLeft = floor(w * right);


switch barPos{1}
    case 'wide'             % wide
        switch barPos{2}
            case 'top'          % top
                detPixel(1,w,startPixelTop,h,1);
                %changeCol(1,w,startPixelTop,remPix,1);
            otherwise           % botton
                detPixel(1,w,startPixelBotton,1,-1);
                %changeCol(1,w,startPixelBotton,remPix,-1);
        end
    otherwise               % heigh
        switch barPos{2}
            case 'right'        % right
                detPixel(startPixelRight,1,1,h,-1);
                %changeCol(startPixelRight,remPix,1,h,-1);
            otherwise           % left
                detPixel(startPixelLeft,w,1,h,1);
                %changeCol(startPixelLeft,remPix,h,1);
        end
end
image(A)

%% Functions needed
% here are the Function that are needed to determine the Range of Pixels to
% remove and the Function to change the Color of these Range to
% Backgroundcolor

    function detPixel(startWidth,stopWidth,startHeight,stopHeight,searchDirection)
        % Function that determines the Range of the Pixels to be
        % color-changed
        
        % Initialize
        search = true;
        m=startWidth;
        % Loop through Width
        while search == true && startWidth ~= stopWidth
            % initialise search-bit for every Width-Pixel
            search = false;
            % Loop through Height
            for n = startHeight:-searchDirection:stopHeight
                if A(n,m,1) ~= bgcolorRed || A(n,m,2) ~= bgcolorGreen || A(n,m,2) ~= bgcolorBlue
                    % if one pixel is found, we need to search further
                    search = true;
                    continue;
                end
            end
            % if no pixel was found in the whole column (Width-Pixel) that has a different color
            % then the Background search-bit is still false!
            if search == false
                % till here we need to change the color (5 Pixel additional to be sure)
                return;
            else
                % set Line to BG-Color
                for n = startHeight:-searchDirection:stopHeight
                 	A(n,m,1) = bgcolorRed;
                    A(n,m,2) = bgcolorGreen;
                    A(n,m,3) = bgcolorBlue;
                end
            end
            % next Pixel to the left
            m = m + searchDirection;
        end
        
    end

    function changeCol(startWidth,stopWidth,startHeight,stopHeight,removeDirection)
        % Function that changes the Color in the specified Area 
        %(startPixel to RemovePixel) to BackgroundColor
        for j=remPixel:-removeDirection:startPixel
            for k=1:1:widthOrHeight
                A(k,j,1) = 255;
                A(k,j,2) = 255;
                A(k,j,3) = 255;
            end
        end
    end
end