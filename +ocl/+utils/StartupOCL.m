% Copyright 2019 Jonas Koenemann, Moritz Diehl, University of Freiburg
% Redistribution is permitted under the 3-Clause BSD License terms. Please
% ensure the above copyright notice is visible in any derived work.
%
function StartupOCL(in)
  % StartupOCL(workingDirLocation)
  % StartupOCL(octaveClear)
  %
  % Startup script for OpenOCL
  % Adds required directories to the path. Sets up a folder for the results
  % of tests and a folder for autogenerated code.
  %
  % inputs:
  %   workingDirLocation - path to location where the working directory
  %                        should be created.

  oclPath  = fileparts(which('ocl'));

  if isempty(oclPath)
    error('Can not find OpenOCL. Add root directory of OpenOCL to the path.')
  end

  workspaceLocation = fullfile(oclPath, 'Workspace');
  octaveClear = false;

  if nargin == 1 && (islogical(in)||isnumeric(in))
    octaveClear = in;
  elseif nargin == 1 && ischar(in)
    workspaceLocation = in;
  elseif nargin == 1
    oclError('Invalid argument.')
  end

  % add current directory to path
  addpath(pwd);

  % create folders for tests and autogenerated code
  testDir     = fullfile(workspaceLocation,'test');
  exportDir   = fullfile(workspaceLocation,'export');
  [~,~] = mkdir(testDir);
  [~,~] = mkdir(exportDir);

  % set environment variables for directories
  setenv('OPENOCL_PATH', oclPath)
  setenv('OPENOCL_TEST', testDir)
  setenv('OPENOCL_EXPORT', exportDir)
  setenv('OPENOCL_WORK', workspaceLocation)

  % setup directories
  addpath(oclPath)
  addpath(exportDir)
  addpath(fullfile(oclPath,'CasadiLibrary'))
  
  addpath(fullfile(oclPath,'doc'))

  addpath(fullfile(oclPath,'Core'))
  addpath(fullfile(oclPath,'Core','Variables'))
  addpath(fullfile(oclPath,'Core','Variables','Variable'))
  addpath(fullfile(oclPath,'Core','utils'))
  
  if ~exist(fullfile(oclPath,'Lib','casadi'), 'dir')
    r = mkdir(fullfile(oclPath,'Lib','casadi'));
    oclAssert(r, 'Could not create direcotory in Lib/casadi');
  end
  
  addpath(fullfile(oclPath,'Lib'))
  addpath(fullfile(oclPath,'Lib','casadi'))

  % check if casadi is already installed (need to wait shortly for path update)
  pause(0.1)
  casadiFound = checkCasadi(fullfile(oclPath,'Lib','casadi'));

  % install casadi into Lib folder
  if ~casadiFound 
    fprintf(2,'\nYour input is required! Please read below:\n')
    
    if ispc && verAtLeast('matlab','9.0')
      % Windows, >=Matlab 2016a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2016a-v3.4.5.zip';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.4')
      % Windows, >=Matlab 2014b
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2014b-v3.4.5.zip';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.3')
      % Windows, >=Matlab 2014a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2014a-v3.4.5.zip';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.1')
      % Windows, >=Matlab 2013a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2013a-v3.4.5.zip';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    
    elseif isunix && ~ismac && verAtLeast('matlab','8.4')
      % Linux, >=Matlab 2014b
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-linux-matlabR2014b-v3.4.5.tar.gz';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif isunix && ~ismac && verAtLeast('matlab','8.3')
      % Linux, >=Matlab 2014a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-linux-matlabR2014a-v3.4.5.tar.gz';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    
    elseif ismac && verAtLeast('matlab','8.5')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2015a-v3.4.5.tar.gz';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif ismac && verAtLeast('matlab','8.4')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2014b-v3.4.5.tar.gz';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    elseif ismac && verAtLeast('matlab','8.3')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2014a-v3.4.5.tar.gz';
      downloadCasadi(oclPath, path, filename, fullfile(oclPath,'Lib','casadi'));
    else
      oclInfo(['Could not set up CasADi for you system.', ...
               'You need to install CasADi yourself and add it to your path.'])
    end
  end
  
  casadiFound = checkCasadiWorking();
  if casadiFound
    oclInfo('CasADi is up and running!')
  else
    oclError('Go to https://web.casadi.org/get/ and setup CasADi.');
  end

  % remove properties function in Variable.m for Octave which gives a
  % parse error
  if isOctave()
    variableDir = fullfile(oclPath,'Core','Variables','Variable');
    %rmpath(variableDir);

    vFilePath = fullfile(exportDir, 'Variable','Variable.m');
    if ~exist(vFilePath,'file') || octaveClear
      delete(fullfile(exportDir, 'Variable','V*.m'))
      status = copyfile(variableDir,exportDir);
      assert(status, 'Could not copy Variables folder');
    end

    vFileText = fileread(vFilePath);
    searchPattern = 'function n = properties(self)';
    replacePattern = 'function n = ppp(self)';
    pIndex = strfind(vFileText,searchPattern);

    if ~isempty(pIndex)
      assert(length(pIndex)==1, ['Found multiple occurences of properties ',...
                                 'function in Variable.m; Please reinstall ',...
                                 'OpenOCL.'])
      newText = strrep(vFileText,searchPattern,replacePattern);
      fid=fopen(vFilePath,'w');
      fwrite(fid, newText);
      fclose(fid);
    end
    addpath(fullfile(exportDir,'Variable'));
  end

  % travis-ci
  if isOctave()
    args = argv();
    if length(args)>0 && args{1} == '1'
      nFails = runTests(1);
      if nFails > 0
        exit(nFails);
      end
    end
  end

  oclInfo('OpenOCL startup procedure finished successfully.')
  
end

function downloadCasadi(oclPath, path, filename, dest)

  confirmation = [ '\n', 'Dear User, if you continue, CasADi will be downloaded from \n', ...
                   path, filename, ' \n', ...
                   'and saved to the Workspace folder. The archive will be extracted \n', ...
                   'to the Lib folder. This will take a few minutes. \n\n', ...
                   'Hit [enter] to continue: '];
  m = input(confirmation,'s');
  
  if strcmp(m, 'n') || strcmp(m, 'no')
    oclError('You did not agree to download CasADi. Either run again or set-up CasADi manually.');
  end
  
  archive_destination = fullfile(oclPath, 'Workspace', filename);

  if ~exist(archive_destination, 'file')
    oclInfo('Downloading...')
    websave(archive_destination, [path,filename]);
  end
  oclInfo('Extracting...')
  [~,~,ending] = fileparts(archive_destination);
  if strcmp(ending, '.zip')
    unzip(archive_destination, dest)
  else
    untar(archive_destination, dest)
  end
end

function r = checkCasadi(path)

  cur_path = pwd;
  cd(path)
  
  if ~exist(fullfile(path,'+casadi','SX.m'),'file') > 0
    r = false;
  else
    try
      casadi.SX.sym('x');
      r = true;
    catch e
      cd(cur_path)
      oclInfo(e);
      casadiNotWorkingError();
    end
  end
  cd(cur_path)
end

function r = checkCasadiWorking()
  try
    casadi.SX.sym('x');
    r = true;
  catch e
    oclInfo(e);
    casadiNotWorkingError();
  end
end

function r = verAtLeast(software, version_number)
  r = ~verLessThan(software,version_number);
end

function casadiNotWorkingError
  oclError(['Casadi installation in the path found but does not ', ...
            'work properly. Try restarting Matlab. Remove all ', ...
            'casadi installations from your path. Run ocl.utils.clean. OpenOCL will ', ...
            'then install the correct casadi version for you.']);
end
