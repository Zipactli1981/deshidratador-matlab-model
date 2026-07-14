function out = inspect_bounds_source_v96z_f3()
% INSPECT_BOUNDS_SOURCE_v96z_f3
%
% Inspecciona líneas relacionadas con lb, ub, bounds, lower, upper y nvars
% en el runner original y en el clon seed-aware.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica archivos.

    rootDir = setup_v05_paths();
    productionDir = fullfile(rootDir,'02_src_limpio','production');
    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    reviewDir = fullfile(articleRoot,'review');
    tablesDir = fullfile(articleRoot,'tables');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    files = [
    string(fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m.m'));
    string(fullfile(productionDir,'run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m'));
    string(fullfile(productionDir,'v96z_rngfix_smoke.m'))
];

    patterns = [
        "lb"
        "ub"
        "bounds"
        "bound"
        "lower"
        "upper"
        "nvars"
        "xBounds"
        "varBounds"
        "gamultiobj"
    ];

    rows = {};

    for f = 1:numel(files)
        filePath = files(f);
        if ~isfile(filePath)
            continue;
        end

        txt = splitlines(string(fileread(filePath)));

        for i = 1:numel(txt)
            line = txt(i);
            lineTrim = strtrim(line);

            if strlength(lineTrim) == 0
                continue;
            end

            hit = false;
            matched = strings(0,1);

            for p = 1:numel(patterns)
                if contains(lower(lineTrim), lower(patterns(p)))
                    hit = true;
                    matched(end+1,1) = patterns(p); %#ok<AGROW>
                end
            end

            if hit
                row = struct();
                row.file = string(filePath);
                row.file_short = string(get_file_name(filePath));
                row.line_number = i;
                row.matched_patterns = strjoin(matched,", ");
                row.line_text = lineTrim;
                rows{end+1,1} = row; %#ok<AGROW>
            end
        end
    end

    if isempty(rows)
        T = table();
    else
        T = struct2table(vertcat(rows{:}));
    end

    outCsv = fullfile(tablesDir,'inspect_bounds_source_v96z_f3_lines.csv');
    writetable(T,outCsv);

    reportMd = fullfile(reviewDir,'INSPECT_BOUNDS_SOURCE_v96z_f3.md');

    fid = fopen(reportMd,'w');
    fprintf(fid,'# INSPECT_BOUNDS_SOURCE_v96z_f3\n\n');
    fprintf(fid,'## Purpose\n\n');
    fprintf(fid,'Inspect source lines related to bounds and gamultiobj without executing GA or model.\n\n');

    fprintf(fid,'## Matched lines\n\n');
    fprintf(fid,'| file | line | patterns | text |\n');
    fprintf(fid,'|---|---:|---|---|\n');

    for i = 1:height(T)
        fprintf(fid,'| `%s` | %d | `%s` | `%s` |\n', ...
            T.file_short(i), T.line_number(i), sanitize_md(T.matched_patterns(i)), sanitize_md(T.line_text(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'INSPECT_BOUNDS_SOURCE_v96z_f3.mat');
    save(outMat,'T','files','patterns','outCsv','reportMd','outMat');

    out = struct();
    out.status = 'INSPECT_BOUNDS_SOURCE_v96z_f3_COMPLETED';
    out.T = T;
    out.outCsv = outCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== INSPECT_BOUNDS_SOURCE_v96z_f3 ===')
    disp(out.status)
    disp('=== MATCHED LINES ===')
    disp(out.T)
    disp('=== REPORT ===')
    disp(out.reportMd)
end

function name = get_file_name(filePath)
    [~,n,e] = fileparts(filePath);
    name = [n e];
end

function s = sanitize_md(x)
    s = string(x);
    s = replace(s, newline, " ");
    s = replace(s, "|", "\|");
    s = replace(s, "`", "'");
end