function [Array,ElementCfg] = SPF_AddElements(Array,ElementCfg)
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
global SPF_FLAGS;
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
            ElementCfg.Distance*cos(ElementCfg.Theta)*cos(ElementCfg.Phi-pi/2) ...
            ... The Phi is with reference to the y axis
            ElementCfg.Distance*cos(ElementCfg.Theta)*cos(ElementCfg.Phi) ...
            ElementCfg.Distance*sin(ElementCfg.Theta) ...
            ];
    end
end
%% Create shape
if true
    %% Single
    if strcmpi(ElementCfg.Shape,'Single')
        %% Single
        newElements={[0 0 0]};
    elseif strcmpi(ElementCfg.Shape,'ula')
        %% ULA
        %% Create the ula on the x axis (y,z) = (0,0)
        xVec=num2cell(...
            linspace(...
            -0.5*ElementCfg.ShapeCfg.Size, ...
            0.5*ElementCfg.ShapeCfg.Size, ...
            ElementCfg.ShapeCfg.nElements ...
            ));
        newElements=cellfun(@(X) [X,0,0],xVec,'UniformOutput',false);
    elseif strcmpi(ElementCfg.Shape,'NESTED_ARRAYS_sensors')
        %% NESTED_ARRAYS_sensors
        %% Create the ula on the x axis (y,z) = (0,0)
        [...
            newElements,...
            Nd_Tilda,...
            U1,...
            Nd,...
            Ns,...
            P,...
            N1_s,...
            N2_s,...
            lambda1,...
            lambda2,...
            DOF,...
            DenseArrayGenerator,...
            SparseArrayGenerator ...
            Sparse_mVEC,...
            Sparse_nVEC,...
            Dense_mVEC,...
            Dense_nVEC, ...
            K1,...
            K2 ...
            ]=...
            SPF_NESTED_ARRAYS_GenerateSenors(ElementCfg);
        ElementCfg.Nd_Tilda=Nd_Tilda;
        ElementCfg.U1=U1;
        ElementCfg.Nd=Nd;
        ElementCfg.P=P;
        ElementCfg.Ns=Ns;
        ElementCfg.N1_s=N1_s;
        ElementCfg.N2_s=N2_s;
        ElementCfg.lambda1=lambda1;
        ElementCfg.lambda2=lambda2;
        ElementCfg.DOF=DOF;
        ElementCfg.DenseArrayGenerator=DenseArrayGenerator;
        ElementCfg.SparseArrayGenerator=SparseArrayGenerator;
        ElementCfg.Sparse_mVEC=Sparse_mVEC;
        ElementCfg.Sparse_nVEC=Sparse_nVEC;
        ElementCfg.Dense_mVEC=Dense_mVEC;
        ElementCfg.Dense_nVEC=Dense_nVEC;
        ElementCfg.K1=K1;
        ElementCfg.K2=K2;
    else
        assert('not implemented yet');
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
Orientation_Theta=ElementCfg.ShapeCfg.Orientation.Theta;
Orientation_Phi=ElementCfg.ShapeCfg.Orientation.Phi;
if length(unique(y_VEC))==1 && length(unique(z_VEC))==1
    %{
    If all y values are the same and also all z values are the same, than
    the rotation around the x axis shouldnt be the first rotation because
    it will not do anything.
    %}
    newElements_Oriented=cellfun(...
        @(X) ...
        RotMat_Theta(Orientation_Theta) ...
        *RotMat_Phi(Orientation_Phi) ...
        *X(:),...
        newElements,...
        'UniformOutput',false);
else
    newElements_Oriented=cellfun(...
        @(X) ...
        RotMat_Phi(Orientation_Phi) ...
        *RotMat_Theta(Orientation_Theta) ...
        *X(:),...
        newElements,...
        'UniformOutput',false);
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
if SPF_FLAGS.VERBOSE
    %% DEBUG
    close all;
    x_ROTVEC=cellfun(@(X) X(1),newElements_Oriented);
    y_ROTVEC=cellfun(@(X) X(2),newElements_Oriented);
    z_ROTVEC=cellfun(@(X) X(3),newElements_Oriented);
    x_ROTVEC_POS=cellfun(@(X) X(1),newElements_Oriented_Positioned);
    y_ROTVEC_POS=cellfun(@(X) X(2),newElements_Oriented_Positioned);
    z_ROTVEC_POS=cellfun(@(X) X(3),newElements_Oriented_Positioned);
    figure;
    subplot(1,3,1);
    scatter3(x_VEC,y_VEC,z_VEC);
    title('before rotation and positioning');
    xlabel('X axis');
    ylabel('Y axis');
    zlabel('Z axis');
    subplot(1,3,2);
    scatter3(x_ROTVEC,y_ROTVEC,z_ROTVEC);
    title(['after rotation. \Phi= ' num2str(f_convert_rad_to_deg(Orientation_Phi)) ...
        '[deg] \Theta= ' num2str(f_convert_rad_to_deg(Orientation_Theta)) '[deg]']);
    xlabel('X axis');
    ylabel('Y axis');
    zlabel('Z axis');
    subplot(1,3,3);
    scatter3(x_ROTVEC_POS,y_ROTVEC_POS,z_ROTVEC_POS);
    title(['after rotation and positioning. pos='  num2str(ElementCfg.Position)]);
    xlabel('X axis');
    ylabel('Y axis');
    zlabel('Z axis');
    close all;
end
%% Add to the Array
Array=[...
    Array ...
    Array_Addition ...
    ];
end