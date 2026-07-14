function report = audit_static_hybrid_irradiance(project_root)
%AUDIT_STATIC_HYBRID_IRRADIANCE Static scan for irradiance nulling.
%
% Scans:
%   opt_tunel_mod2, run_opt_GA, opt_fun, opt_fun2, opt_fun3 and wrappers.
%
% This is diagnostic only. If hybrid irradiance is actually corrected, that
% must be registered as a type D computational correction.

    if nargin < 1 || isempty(project_root)
        project_root = pwd;
    end

    report.created_at = datetime("now");
    report.created_by_function = "audit_static_hybrid_irradiance";
    report.mode = "STATIC_ANALYSIS_ONLY";

    activeDir = fullfile(project_root,'03_original_model','01_active_original');
    wrappersDir = fullfile(project_root,'02_src_limpio','wrappers');

    targetNames = ["opt_tunel_mod2", "run_opt_GA", "opt_fun", "opt_fun2", "opt_fun3"];
    patterns = ["I(i)=0", "I(i) = 0", "I = 0", "Irradiacion = 0", "I_effective = 0"];

    report.hits = {};

    for k = 1:numel(targetNames)
        for ext = [".m", ".mlx"]
            file = fullfile(activeDir, targetNames(k) + ext);
            if isfile(file)
                txt = local_read_text(file);
                report = local_scan_file(report, file, txt, patterns);
            end
        end
    end

    if isfolder(wrappersDir)
        files = [dir(fullfile(wrappersDir,"*.m")); dir(fullfile(wrappersDir,"*.mlx"))];
        for k = 1:numel(files)
            file = fullfile(files(k).folder, files(k).name);
            txt = local_read_text(file);
            report = local_scan_file(report, file, txt, patterns);
        end
    end

    if isempty(report.hits)
        report.status = "NO_STATIC_IRRADIANCE_NULLING_PATTERN_FOUND";
    else
        report.status = "STATIC_IRRADIANCE_NULLING_PATTERN_FOUND";
    end

    logsDir = fullfile(project_root,"06_outputs","logs");
    if ~exist(logsDir,"dir"), mkdir(logsDir); end

    report.output_file = fullfile(logsDir, "AUD_HYBRID_IRR_STATIC_" + string(datestr(now,"yyyymmdd")) + ".txt");

    fid = fopen(report.output_file,"w");
    fprintf(fid,"AUD_HYBRID_IRR_STATIC\n\n");
    fprintf(fid,"status: %s\n", report.status);
    fprintf(fid,"mode: %s\n", report.mode);
    fprintf(fid,"hits: %d\n\n", numel(report.hits));
    for k = 1:numel(report.hits)
        h = report.hits{k};
        fprintf(fid,"file: %s\npattern: %s\nline_or_context: %s\n\n", h.file, h.pattern, h.context);
    end
    fclose(fid);
end

function report = local_scan_file(report, file, txt, patterns)
    for p = 1:numel(patterns)
        idx = strfind(txt, patterns(p));
        for j = 1:numel(idx)
            a = max(1, idx(j)-80);
            b = min(strlength(txt), idx(j)+120);
            hit.file = string(file);
            hit.pattern = string(patterns(p));
            hit.context = extractBetween(string(txt), a, b);
            report.hits{end+1} = hit;
        end
    end
end

function txt = local_read_text(file)
    [~,~,ext] = fileparts(file);
    if strcmpi(ext,".m")
        txt = fileread(file);
    else
        txt = "";
        try
            unzipDir = tempname;
            mkdir(unzipDir);
            cleanup = onCleanup(@() rmdir(unzipDir,"s"));
            unzip(file, unzipDir);
            xmlFile = fullfile(unzipDir,"matlab","document.xml");
            if isfile(xmlFile)
                txt = fileread(xmlFile);
                txt = regexprep(txt,"<[^>]+>"," ");
                txt = strrep(txt,"&lt;","<");
                txt = strrep(txt,"&gt;",">");
                txt = strrep(txt,"&amp;","&");
            end
        catch
            txt = "";
        end
    end
end
