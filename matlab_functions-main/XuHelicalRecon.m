function img = XuHelicalRecon(s_js_fbp)
%Additional Parameters
%"DetectorVerticalFilterWidth": //Perform gausian blur in the vertical
%direction of the detector

%"InputIsProjImage": // whether input is proj image or sinogram image

js_fbp = XuReadJsonc(s_js_fbp);
%read the jsonc file

%in our convention, for pitch>0, the gantry moves upward;
%or the object moves downward in the proj image

%change ".*" in the regular expression to "*"
inputfiles_matlab = strrep(js_fbp.InputFiles,'.*','*');
D = dir([js_fbp.InputDir '/' inputfiles_matlab]);

for file_idx = 1:length(D)
    fprintf('Processing File #%d/%d ...\n', [file_idx,length(D)]);

    if isfield(js_fbp,'InputIsProjImage') && js_fbp.InputIsProjImage == true
        prj_img = XuReadRaw([js_fbp.InputDir '/' D(file_idx).name],...
            [js_fbp.DetectorElementCountHorizontal,js_fbp.DetectorElementCountVertical,js_fbp.SinogramHeight]);
        prj_img = flip(prj_img,2);
        %For our recon program, the convention is that the first row is with negative Z position while the
        %last is with positive Z position;
        %Therefore, we need to flip data in the  detector vertical direction.
    else
        sgm = XuReadRaw([js_fbp.InputDir '/' D(file_idx).name],...
            [js_fbp.DetectorElementCountHorizontal,js_fbp.SinogramHeight,js_fbp.DetectorElementCountVertical]);
        prj_img = permute(sgm,[1 3 2]);
        clear sgm;
    end

    if isfield(js_fbp,'DetectorVerticalFilterWidth') && js_fbp.DetectorVerticalFilterWidth
        prj_img = imgaussfilt3(prj_img,[0.001,js_fbp.DetectorVerticalFilterWidth,0.001]);
        %perform a gaussian filtration in the vertical detector direction
    end

    mag_ratio_isocenter =  js_fbp.SourceDetectorDistance/js_fbp.SourceIsocenterDistance;
    
    isocenter_coverage = js_fbp.DetectorElementCountVertical * js_fbp.DetectorElementHeight...
        / mag_ratio_isocenter;

    %distance the object moves per each round
    distance_per_round = js_fbp.HelicalPitch ...
        *isocenter_coverage;

    %number of rounds in this scan
    num_rounds = abs(js_fbp.TotalScanAngle) / 360;

    %distance the object moves per view
    distance_per_view = distance_per_round /(js_fbp.Views/num_rounds);

    %angle between adjacent views (in degree)
    angle_per_view = js_fbp.TotalScanAngle/js_fbp.Views;

    %fan angle defined by the detector (for flat panel detector)
    gamma_max = 2* atand(0.5*js_fbp.DetectorElementCountHorizontal*js_fbp.DetectorElementWidth/js_fbp.SourceDetectorDistance);

    %define short scan range
    short_scan_range = 360/abs(js_fbp.HelicalPitch);
    if short_scan_range < 180 + gamma_max
        %if short scan range is smaller than 180+ gamma_max, use extrapolation
        short_scan_range = 180 + gamma_max;
    end
    pixel_height = js_fbp.VoxelHeight;%mm
    z_pos_array = (0 + isocenter_coverage/2*sign(js_fbp.HelicalPitch)):...
        (pixel_height*sign(js_fbp.HelicalPitch)):...
        distance_per_view*js_fbp.Views - isocenter_coverage/2*sign(js_fbp.HelicalPitch);
    fprintf('Reconstruction Z Coverage: %.1f mm to %.1f mm\n',[z_pos_array(1), z_pos_array(end)]);
    view_count = ceil(short_scan_range/abs(angle_per_view));
    short_scan_range = view_count*abs(angle_per_view);
    sgm_rebin = zeros(js_fbp.DetectorElementCountHorizontal,view_count,length(z_pos_array));
    fprintf('Size of Rebinned Sinogram is %d x %d x %d\n',...
        [js_fbp.DetectorElementCountHorizontal,view_count,length(z_pos_array)]);
    image_rotation_array=zeros(1,length(z_pos_array));

    p = MgCmdLineProgressBar('Perform Rebinning: Slice #');
    for z_pos_idx = 1:length(z_pos_array)
        %p.print(z_pos_idx,length(z_pos_array));
        z_pos = z_pos_array(z_pos_idx);
        view_idx_v_equal_0 = z_pos / distance_per_view + 1;
        
        
        %find the view_idx when isocenter is aligned with the central plane

        view_begin = view_idx_v_equal_0 - 1/2*view_count + 1/2;%view_idx_begin
        
        view_begin = floor(view_begin)

        view_end = view_begin + view_count-1;%view_idx_end
        image_rotation_array(z_pos_idx) = (view_begin-1) * angle_per_view;

        %
        for view_idx = view_begin:1:view_end
            data = zeros(size(prj_img,1),1);
            view_idx_floor = floor(view_idx);
            
            w_view = view_idx - view_idx_floor;
            %weight for view_idx for interpolation purpose

            if view_idx_floor>=1 && view_idx_floor<=js_fbp.Views-1
                v_pos = (z_pos - view_idx*distance_per_view)*mag_ratio_isocenter...
                    - js_fbp.DetectorOffsetVertical;
                v_idx = v_pos/js_fbp.DetectorElementHeight +...
                    (1 + js_fbp.DetectorElementCountVertical)/2;

                if v_idx>=js_fbp.DetectorElementCountVertical
                    data = prj_img(:,js_fbp.DetectorElementCountVertical,view_idx_floor)*(1-w_view)+...
                        prj_img(:,js_fbp.DetectorElementCountVertical,view_idx_floor+1)*w_view;
                elseif v_idx<=1
                    data = prj_img(:,1,view_idx_floor)*(1-w_view)+...
                        prj_img(:,1,view_idx_floor+1)*w_view;
                else
                    w = v_idx - floor(v_idx);
                    data_1 = prj_img(:,floor(v_idx),view_idx_floor)*(1-w_view)+...
                        prj_img(:,floor(v_idx),view_idx_floor+1)*w_view;
                    data_2 = prj_img(:,floor(v_idx)+1,view_idx_floor)*(1-w_view)+...
                        prj_img(:,floor(v_idx)+1,view_idx_floor+1)*w_view;
                    data = data_1 * (1-w) + data_2 * w;
                end
                data = data* js_fbp.SourceDetectorDistance/sqrt(js_fbp.SourceDetectorDistance^2+v_pos^2);
            end
            sgm_rebin(:,round(view_idx-view_begin+1),z_pos_idx) = data;
        end
    end
    if ~exist([js_fbp.InputDir '/temp'])
        mkdir([js_fbp.InputDir '/temp']);
    end
    XuWriteRaw([js_fbp.InputDir '/temp/sgm_rebin'],sgm_rebin);
    clear sgm_rebin

    js.Value = image_rotation_array;
    XuStructToJsonc('ImageRotationFile.jsonc',js);

    js_fbp_mod = js_fbp;
    js_fbp_mod.ImageRotationFile = 'ImageRotationFile.jsonc';
    js_fbp_mod.InputFiles = 'sgm_rebin.raw';
    js_fbp_mod.InputDir = [js_fbp_mod.InputDir '/temp'];
    output_file_name = strrep(D(file_idx).name,char(js_fbp.OutputFileReplace{1}),...
        char(js_fbp.OutputFileReplace{2}));
    js_fbp_mod.OutputFileReplace ={'sgm_rebin.raw',output_file_name};
    js_fbp_mod.DetectorElementCountVertical = length(z_pos_array);
    js_fbp_mod.ConeBeam = false;
    js_fbp_mod.TotalScanAngle = short_scan_range * sign(js_fbp.TotalScanAngle);
    js_fbp_mod.HelicalPitch = 0;
    js_fbp_mod.SinogramHeight = view_count;
    js_fbp_mod.Views = view_count;
    js_fbp_mod.ImageDimensionZ = length(z_pos_array);
    fprintf('Perform Reconstruction ...\n');
    img = XuMgfbpFromStructVer2(js_fbp_mod,output_file_name);
end