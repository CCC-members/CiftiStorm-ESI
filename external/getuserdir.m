function userDir = getuserdir
%GETUSERDIR   return the user home directory.
%   USERDIR = GETUSERDIR returns the user home directory using the registry
%   on windows systems and using Java on non windows systems as a string
%
%   Example:
%      getuserdir() returns on windows
%           C:\Documents and Settings\MyName\Eigene Dateien
if ispc
    userDir = getenv('USERPROFILE');
    userDir = fullfile(userDir,'.brainstorm'); 
else
    userDir = char(java.lang.System.getProperty('user.home'));
    userDir = fullfile(userDir,'.brainstorm');
end
