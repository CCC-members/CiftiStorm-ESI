function sub_to_FSAve = get_FSAve_Surfaces_interpolation(properties,subID)
%GET_FSAVE_SURFACES_INTERPOLATION Summary of this function goes here

ProtocolInfo    = bst_get('ProtocolInfo');
anat_path       = ProtocolInfo.SUBJECTS;
sSubject        = bst_get('Subject', subID);
Surfaces        = sSubject.Surface;
sub_to_FSAve    = [];

if(~isequal(properties.anatomy_params.anatomy_type.type,1))
    anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
    layer_desc      = anatomy_type.layer_desc.desc;
    if(isequal(layer_desc,'white') || isequal(layer_desc,'midthickness') || isequal(layer_desc,'pial'))
        type = 'single';
    else
        type = 'fs_ave';
    end
    for i=1:length(Surfaces)
        surface = Surfaces(i);
        if(isequal(surface.SurfaceType,'Cortex'))
            comment = split(surface.Comment,'_');
            desc    = comment{2};
            resol   = comment{3};
            fix     = comment{end};
            switch type
                case 'single'
                    if(isequal(resol,'high')) iHigh = i; end
                    if(isequal(resol,'low') && isequal(resol,fix)) iLow = i; end
                case 'fs_ave'
                    if(isequal(resol,'high') && isequal(desc,'pial')) iHigh = i; end
                    if(isequal(resol,'low') && isequal(desc,'pial') && isequal(resol,fix)) iLow = i; end
            end
        end
    end
    %%
    %%  Get High and Low Cortex
    %%
    CortexFileLow           = sSubject.Surface(iLow).FileName;
    BSTCortexFileLow        = fullfile(anat_path, CortexFileLow);
    ScLow                   = load(BSTCortexFileLow);
    disp ("-->> Getting FSAve surface corregistration");
    fsave_inds_template     = load('templates/FSAve_64K_8K_coregister_indms.mat');
    CortexFileHigh          = sSubject.Surface(iHigh).FileName;
    BSTCortexFileHigh       = fullfile(anat_path, CortexFileHigh);
    ScHigh                  = load(BSTCortexFileHigh);
    % Finding near FSAve vertices on subject surface
    sub_to_FSAve            = find_interpolation_vertices(ScHigh,ScLow, fsave_inds_template);
end
end