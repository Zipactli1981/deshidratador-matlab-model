function report = inspect_solar_branch_lines_v620()
% INSPECT_SOLAR_BRANCH_LINES_v620
% Inspección textual de líneas críticas del modo solar.
% No modifica archivos.
% No ejecuta AG.
% No corrige todavía.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    files = {
        which('opt_tunel_mod2_v10_energy_mode_corrected')
        which('objective_productive_corrected_v611')
        which('tunel_mod2')
    };

    files = files(~cellfun(@isempty,files));

    patterns = {
        'solar'
        'hybrid'
        'gasLP'
        'calor_aux'
        'I_effective'
        'I(i)=0'
        'I(i) = 0'
        'I_busc'
        'Q_aux_tot'
        'Irradiacion'
        'dry_time'
        'MR'
        'M ='
        'M='
        'while'
        'break'
        'ode23tb'
        'T_min'
        't_rec_ini'
        'r_div2'
    };

    rows = {};

    contextRadius = 3;

    for f = 1:numel(files)
        filePath = files{f};
        txt = fileread(filePath);
        lines = regexp(txt, '\r\n|\n|\r', 'split');

        for p = 1:numel(patterns)
            pat = patterns{p};

            for k = 1:numel(lines)
                if contains(lines{k}, pat)
                    i1 = max(1, k-contextRadius);
                    i2 = min(numel(lines), k+contextRadius);

                    context = strings(i2-i1+1,1);
                    for c = i1:i2
                        context(c-i1+1) = sprintf('%04d: %s', c, lines{c});
                    end

                    row = struct();
                    row.file = string(filePath);
                    row.pattern = string(pat);
                    row.line_number = k;
                    row.line_text = string(lines{k});
                    row.context = strjoin(context, newline);

                    rows{end+1,1} = row; %#ok<AGROW>
                end
            end
        end
    end

    if isempty(rows)
        T = table();
    else
        T = struct2table(vertcat(rows{:}));
    end

    % Guardar reporte en la corrida productiva más reciente
    baseDir = fullfile(rootDir,'05_runs','productive_v614b');
    d = dir(baseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'PRODUCTIVE_GA_CORRECTED_v614_');
    end
    d = d(keep);

    if isempty(d)
        outDir = fullfile(rootDir,'06_outputs');
    else
        [~,idx] = max([d.datenum]);
        outDir = fullfile(baseDir,d(idx).name,'logs');
    end

    if ~isfolder(outDir)
        mkdir(outDir);
    end

    outCsv = fullfile(outDir,'SOLAR_BRANCH_LINE_INSPECTION_v620.csv');
    outTxt = fullfile(outDir,'SOLAR_BRANCH_LINE_INSPECTION_v620.txt');
    outMat = fullfile(outDir,'SOLAR_BRANCH_LINE_INSPECTION_v620.mat');

    writetable(T,outCsv);
    save(outMat,'T','files','patterns');

    fid = fopen(outTxt,'w');
    fprintf(fid,'SOLAR-BRANCH-LINE-INSPECTION-001\n');
    fprintf(fid,'status: SOLAR_BRANCH_LINE_INSPECTION_COMPLETED\n');
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    for i = 1:height(T)
        fprintf(fid,'============================================================\n');
        fprintf(fid,'file: %s\n', T.file(i));
        fprintf(fid,'pattern: %s\n', T.pattern(i));
        fprintf(fid,'line: %d\n', T.line_number(i));
        fprintf(fid,'%s\n\n', T.context(i));
    end

    fclose(fid);

    report = struct();
    report.status = 'SOLAR_BRANCH_LINE_INSPECTION_COMPLETED';
    report.files = files;
    report.patterns = patterns;
    report.table = T;
    report.outCsv = outCsv;
    report.outTxt = outTxt;
    report.outMat = outMat;

    disp('=== SOLAR_BRANCH_LINE_INSPECTION_v620 ===')
    disp(report.status)
    disp('=== OUTPUT TXT ===')
    disp(report.outTxt)
    disp('=== MATCH COUNT ===')
    disp(height(T))

    % Mostrar subconjunto crítico en pantalla
    if ~isempty(T)
        critical = contains(T.pattern, ["solar","calor_aux","I_effective","I(i)=0","I(i) = 0","MR","T_min"]);
        disp('=== CRITICAL MATCHES ===')
        disp(T(critical, {'file','pattern','line_number','line_text'}))
    end
end