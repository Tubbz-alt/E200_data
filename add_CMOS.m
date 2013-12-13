function data = add_CMOS(data,param,e_PID,e_scan_step,e_dataset)
	% ================================================
	% Only add if cmos cams exist.
	% ================================================
	if isfield(param,'cam_CMOS')

		% ================================================
		% Only add if cmos cams exist.
		% ================================================
		if size(param.cam_CMOS,1)>0
			% ================================================
			% Iterate for each camera
			% ================================================
			for i=1:size(param.cmos_path,2)
				% ================================================
				% Gather info
				% ================================================
				% Get camera name
				str=param.cam_CMOS{i,1};

				% Path to dir containing files
				path = param.cmos_path{i};
				filelist  = dir(fullfile(path,'*step*.tif'));
				n_i_shots = size(filelist,1);
				if n_i_shots == 0
					rgbvec = [1,0,0];
					printstr = ['No CMOS data found for ' str '!\n'];
					cprintf(rgbvec,printstr);
				end
				step      = zeros(1,n_i_shots);
				pID       = zeros(1,n_i_shots);
				files     = cell(1,n_i_shots);
				% ================================================
				% Iterate for each file
				% ================================================
				for j=1:n_i_shots
					file     = filelist(j).name;
					files{j} = fullfile(get_remoteprefix(),path,file);
					separ    = regexp(file,'_');
					step(j)  = str2num(file(separ(2)+1:separ(3)-1));
					pID(j)   = str2num(file(separ(4)+1:end-4));
				end
				
				% ================================================
				% Find cam background
				% ================================================
				filelist  = dir(fullfile(path,'*step*.tif'));

				% Pass through cam name converter (should do nothing?)
				[filestr,structstr]=cams2filenames(str,param.timestamp);

				bgfile = dir(fullfile(path,'*background*.tif'));
				bgfile = fullfile(path,bgfile.name);

				data.raw.images.(structstr)=struct();
				data.raw.images.(structstr)=replace_field(data.raw.images.(structstr),...
							'background_dat'	, cell_construct(...
												bgfile,...
												1,n_i_shots),...
							'background_format'	, cell_construct('tif',1,n_i_shots));
				names=fieldnames(param.cmos_bg_struct.(str));
				for j=1:size(names,1)
					toadd=param.cmos_bg_struct.(str).(names{j});
					if iscell(toadd)
						data.raw.images.(structstr).(names{j})=cell_construct(toadd,1,n_i_shots);
					else
						data.raw.images.(structstr).(names{j})=ones(1,n_i_shots)*toadd;
					end
				end

				% Camera type is CMOS.
				format=cell_construct('CMOS',1,n_i_shots);
	
				% ================================================
				% Write information gathered into the struct
				% ================================================
	
	
				% Get image UIDs
				option.IMAGE_PID      = pID;
				option.IMAGE_SCANSTEP = step;
				UIDs                  = assign_UID(e_PID,e_scan_step,e_dataset,option);
				i_UID                 = UIDs.image_UID;
		
				data.raw.images.(structstr)=replace_field(data.raw.images.(structstr),...
								'dat'			, files, ...
								'format'		, format, ...
								'isfile'		, ones(1,n_i_shots), ...
								'bin_index'		, [1:n_i_shots], ...
								'UID'			, i_UID, ...
		                    				'PID'                   , pID,...
								'IDtype'		, 'Image');
			end
		end
	end
end
