# CiftiStorm-ESI
A pipeline to integrate “legacy” datasets into a Human Connectome Project (HCP) framework for forward and inverse modeling of Magnetoencephalogram (MEG). Legacy data, which is previous to, or does not match, the particular HCP acquisition or quality standards, is currently the stumbling stone when attempting to align the results of our analyses with the HCP research outputs. Ciftistorm is a FieldTrip’s megconnectome pipeline compliant that extends its capabilities based on BrainStorm, and a broader software ecosystem, enabling the generation of standard megconnectome outputs from diverse sMRI and EEG/MEG inputs. Our pipeline focuses on HCP-compatible forward and inverse model processing employing Electroencephalogram (EEG), or Magnetoencephalogram (MEG), and Structural Magnetic Resonance Imaging (sMRI) legacy acquisitions. As we demonstrate our pipeline’s outputs are statistically equivalent employing HCP MEG and MRI data, and EEG and MRI data acquired ~10 years before the HCP launch. To ensure standardization, we prioritize robust forward modeling and inverse modeling techniques. We have implemented specialized methods and stringent quality control measures to effectively address challenges associated with forward modeling under various data conditions.

% Authors
 - Ariosky Areces Gonzalez
 - Deirel Paz Linares

% November 15, 2019

## Check our [wiki](https://github.com/CCC-members/CiftiStorm/wiki)
* the [[FAQ]](https://github.com/CCC-members/CiftiStorm/wiki/FAQ) and
* the [[Installation and Usage Instructions]](https://github.com/CCC-members/CiftiStorm/wiki/Installation-and-Usage-Instructions) guide


## Parameters configuration
### General process [[File]](https://github.com/CCC-members/CiftiStorm/blob/master/config_properties/general_params.json)
    - modality     --> Electrophysiology data modality (EEG or MEG)
    - name         --> Processing name
    - bst_config   --> Configuration structure for Brainstorm processing
        - protocol_name  --> Brainstorm protocol name
        - protocol_reset --> Reset the protocol information if the protocol already exists in the Brainstorm database (true|false)
        - bst_path       --> Brainstorm Toolbox root directory
        - db_path        --> Path to create the Brainstorm database. (local) Will create it in the user's home directory. Define a real path in another case.
        - after_MaQC     --> Define as false to the first processing and true after channel correction to recompute the Headmodel and the Leadfield.
    - output_path   --> Path directory for the analysis outputs.
    - tmp_path      --> Path directory for temporary files. (local) as default. Define a real directory in another case. 
## Import anatomy process [[File]](https://github.com/CCC-members/CiftiStorm/blob/master/config_properties/process_import_anat.json)
### Anatomy's type parameters
    - anatomy_type:type --> Select the anatomy type to run in the (type_list) structure
    - type_list         --> List of different anatomy configurations.
        1. default_anatomy
            - template_name    --> Brainstorm's Anatomy template name. See **bst_templates/bst_default_anatomy.json** file as reference 
            - default_atlas    --> Brainstorm's default atlas to use in the analysis See
        2. hcp_anat_template
            - base_path        --> Path directory for the anatomy template in HCP format
            - T1w_file_name    --> T1w file name in the HCP structure
            - Atlas_file_name  --> Alas file name in the  HCP Structure
        3. hcp_anat_individual 
            - base_path        --> Path directory for the anatomy template in HCP format
            - T1w_file_name    --> T1w file name in the HCP structure
            - Atlas_file_name  --> Alas file name in the  HCP Structure
    - common_params (Independent parameters for all anatomy types)
        - mri_transformation  --> (Optional)(Transformation file to apply in the MRI)
            - use_transformation  --> (true|false) in case you want to use MRI transformation.
            - base_path           --> Base path directory. Subject's parent directory
            - file_name           --> Reference file path after Subject's directory
        - non_brain_surfaces --> FSL Bet command output
              - base_path           --> FSL Bet root directory
        - layer_desc         --> Layer descriptor structure
            - desc                --> Options <<white>> OR <<midthickness>> OR <<pial>> OR <<bigbrain>> multilayer like bigbrain OR <<fs_LR>> like HCP FSAve (three layers).
        - surfaces_resolution --> Numbers of vertices for downsampling each surface
            - nverthead     --> Scalp's number of vertices. Default: 8000
            - nvertskull    --> Skull's number of vertices. Default: 8000
            - nvertcortex   --> Cortex's number of vertices. Default: 8000        

## Import channel process [[File]](https://github.com/CCC-members/CiftiStorm/blob/master/config_properties/process_import_channel.json)
    - channel_type    -->  Select the type of import channel process to be used. <<1>> Use raw data. <<2>> Use BST default template
        - raw_data    -->  Configuration for Raw data processing
            - base_path     --> Root directory of the raw data
            - file_location --> Reference path for the raw data (after the subject folder)
            - data_format   --> Standard format for the data
            - isfile        --> Define true if the data is a file or false if a folder.
        - import_channel -->    Select the group and name of the sensor layout. See bst_templates/bst_layout_default.json file.
            - group_layout_name    --> 
            - channel_layout_name  -->

## Compute Headmodel process [[File]](https://github.com/CCC-members/CiftiStorm/blob/master/config_properties/process_comp_headmodel.json)
### Default parameter configuration
    - radii          --> Default: [0.88,0.93,1]
    - conductivity   --> Default: [0.33,0.0042,0.33]
    - BemNames       --> Default: ["Scalp","Skull","Brain"]
    - BemCond        --> Default: [1,0.0125,1]
    - BemSelect      --> Default: [true,true,true]
    - Method      --> Recommended options EEG=<<openmeeg>> MEG=<<os_meg>>. Others options <<meg_sphere>> <<eeg_3sphereberg>> <<duneuro>> 
        - value   --> 
    - method_type        -->
        - openmeeg
            - EEGMethod        -->
            - isAdjoint        -->
            - isAdaptative     -->
            - isSplit          -->
            - SplitLength      -->
        - os_meg
            - MEGMethod        -->
        - duneuro
            - FemCond          --> Default: [1.79,0.0080,0.43]
            - FemSelect        --> Default: [1,1,1]
            - Isotropic        --> Default: 1
            - UseTensor        --> Default: 0
            - FemMesh          -->
                - Method       --> <<iso2mesh>> <<brain2mesh>> <<simnibs>> <<roast>> <<fieldtrip>>
                    - value    --> Default:iso2mesh
                - MeshType     --> iso2mesh=<<tetrahedral>>.  simnibs=<<tetrahedral>>. roast=<<hexahedral>>|<<tetrahedral>>.  fieldtrip=<<hexahedral>>|<<tetrahedral>>
                    - value    --> Default: tetrahedral
                - MaxVol       --> iso2mesh Max tetrahedral volume (10=coarse, 0.0001=fine)
                    - value    --> Default: 0.1
                - KeepRatio    --> iso2mesh Percentage of elements kept (1-100%)
                    - value    --> Default: 100
                - MergeMethod  --> iso2mesh <<mergemesh>>|<<mergesurf>> Function used to merge the meshes
                    - value    --> Default: mergesurf
                - VertexDensity--> SimNIBS <<0.1 - X>> setting the vertex density (nodes per mm2)  of the surface meshes
                    - value    --> Default: 0.5
                - NbVertices   --> SimNIBS Number of vertices for the cortex surface imported from CAT12
                    - value    --> Default: 15000
                - NodeShift    --> FieldTrip <<0 - 0.49>> Improves the geometrical properties of the mesh
                    - value    --> Default: 0.3
                - Downsample   --> FieldTrip Integer, Downsampling factor to apply to the volumes before meshing
                    - value    --> Default: 3
                - Zneck        --> Input T1/T2: Cut volumes below neck (MNI Z-coordinate)
                    - value    --> Default: -115

## Run CiftiStorm
* Open CiftiStorm pipeline on Matlab
* Run the following command in Matlab console
>     ciftistorm_esi nogui
>     meegprep
>     bcvareta nogui
* [Getting and running the example data](https://github.com/CCC-members/CiftiStorm/wiki/Getting-and-running-the-example-data)

