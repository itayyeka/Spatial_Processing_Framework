function [Array] = SPF_AddElements(Array,ElementCfg)
%% Defaults
%{
Configurable parameters for sources/sensors are:

Position -
vector of 3 elements (X,Y,Z)
the center position (X,Y,Z) of the source/sensors array.
 
Distnace -
Instead of configuring the center, one can define its
distance from the the reference point. When configuring
Distance, one can also define Theta and Phi.

Phi -
When configuring Distance

Theta -
When configuring Distance

Shape -
String.
As the simulator will grow, more and more shapes of
sources/sensors will be supported (Single,ula,sphere,ball,swarm,
circle etc...)

ShapeCfg -
Record:
* ShapeCfg.Size -   the distance between the two most
distant sources/sensors in the array.
* ShapeCfg.Orientation.Phi
* ShapeCfg.Orientation.Theta
%}
if true
    if ~isfield(ElementCfg,'Position')
        %% Distance
        if ~isfield(ElementCfg,'Distance')
            ElementCfg.Distance=0;
        end
        %% Phi
        if ~isfield(ElementCfg,'Phi')
            ElementCfg.Phi=0;
        end
        %% Theta
        if ~isfield(ElementCfg,'Theta')
            ElementCfg.Theta=0;
        end
    end
    %% Shape
    if ~isfield(ElementCfg,'Shape')
        ElementCfg.Shape='Single';
    end
    %% ShapeCfg
    if ~isfield(ElementCfg,'ShapeCfg')
        ElementCfg.ShapeCfg=[];
        ElementCfg.ShapeCfg.Orientation.Phi=0;
        ElementCfg.ShapeCfg.Orientation.Theta=0;
    else
        %% Size
        assert(isfield(ElementCfg.ShapeCfg,'Size'),...
            'When configuring a shape, one must enter its size');
        %% nElements
        if ~strcmpi(ElementCfg.Shape,'Single')
            assert(isfield(ElementCfg.ShapeCfg,'nElements'),...
                'When configuring a shape, one must enter number of elemetns');
        end
        %% Orientation
        if ~isfield(ElementCfg.ShapeCfg,'Orientation')
            ElementCfg.ShapeCfg.Orientation=[];
        end
        if true
            %% Phi
            if ~isfield(ElementCfg.ShapeCfg.Orientation,'Phi')
                ElementCfg.ShapeCfg.Orientation.Phi=0;
            end
            %% Theta
            if ~isfield(ElementCfg.ShapeCfg.Orientation,'Theta')
                ElementCfg.ShapeCfg.Orientation.Theta=0;
            end
        end
    end
    if ~isfield(ElementCfg,'Position')
        ElementCfg.Position=...
            [...
            ElementCfg.Distance*cos(ElementCfg.Theta)*cos(ElementCfg.Phi) ...
            ElementCfg.Distance*cos(ElementCfg.Theta)*sin(ElementCfg.Phi) ...
            ElementCfg.Distance*sin(ElementCfg.Theta) ...
            ];
    end
end
%% Create shape
if true
    %% Single
    if strcmpi(ElementCfg.Shape,'Single')
        newElements={[0 0 0]};
    end
    %% ULA
    if strcmpi(ElementCfg.Shape,'ula')
        %% Create the ula on the x axis (y,z) = (0,0)
        xVec=num2cell(...
            linspace(...
            -0.5*ElementCfg.ShapeCfg.Size, ...
            0.5*ElementCfg.ShapeCfg.Size, ...
            ElementCfg.ShapeCfg.nElements ...
            ));
        newElements=cellfun(@(X) [X,0,0],xVec,'UniformOutput',false);
    end
end
%% rotate the shape to the wnated orientation
RotMat_Phi= @(Phi) ... rotate around the Z axis left-hand rule
    [...
    cos(-Phi), -sin(-Phi), 0 ...
    ; ...
    sin(-Phi), cos(-Phi), 0 ...
    ;...
    0, 0, 1 ...
    ];
RotMat_Theta= @(Theta) ... rotate around the x axis right-hand rule
    [...
    1,0,0 ...
    ;...
    0,cos(Theta),-sin(Theta) ...
    ; ...
    0,sin(Theta),cos(Theta) ...
    ];
x_VEC=cellfun(@(X) X(1),newElements);
y_VEC=cellfun(@(X) X(2),newElements);
z_VEC=cellfun(@(X) X(3),newElements);
if length(unique(y_VEC))==1 && length(unique(z_VEC))==1
    %{
    If all y values are the same and also all z values are the same, than
    the rotation around the x axis shouldnt be the first rotation because
    it will not do anything.
    %}
    newElements_Oriented=cellfun(...
        @(X) ...
        RotMat_Theta(ElementCfg.ShapeCfg.Orientation.Theta) ...
        *RotMat_Phi(ElementCfg.ShapeCfg.Orientation.Phi) ...
        *X(:),...
        newElements,...
        'UniformOutput',false);
else
    newElements_Oriented=cellfun(...
        @(X) ...
        RotMat_Phi(ElementCfg.ShapeCfg.Orientation.Phi) ...
        *RotMat_Theta(ElementCfg.ShapeCfg.Orientation.Theta) ...
        *X(:),...
        newElements,...
        'UniformOutput',false);
end
if false
    %% DEBUG
    close all;
    x_ROTVEC=cellfun(@(X) X(1),newElements_Oriented);
    y_ROTVEC=cellfun(@(X) X(2),newElements_Oriented);
    z_ROTVEC=cellfun(@(X) X(3),newElements_Oriented);
    figure;
    subplot(1,2,1);
    scatter3(x_VEC,y_VEC,z_VEC);
    subplot(1,2,2);
    scatter3(x_ROTVEC,y_ROTVEC,z_ROTVEC);
end
%% Move the shape to the wanted position
newElements_Oriented_Positioned=cellfun(...
    @(X) X(:)+ElementCfg.Position(:), ...
    newElements_Oriented,...
    'UniformOutput',false);
Array_Addition={};
for ElID=1:numel(newElements_Oriented_Positioned)
    Array_Addition{end+1}.Position=newElements_Oriented_Positioned{ElID};
end
%% Add to the Array
Array=[...
    Array ...
    Array_Addition ...
    ];
end