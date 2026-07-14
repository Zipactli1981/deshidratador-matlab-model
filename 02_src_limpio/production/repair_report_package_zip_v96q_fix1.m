function fix = repair_report_package_zip_v96q_fix1()
% REPAIR_REPORT_PACKAGE_ZIP_v96q_fix1
% 9.6q-fix1 — REPORT-PACKAGE-ZIP-REPAIR-001
%
% Objetivo:
%   Reparar/verificar el ZIP del paquete v96q.
%
% Este paso:
%   - NO ejecuta gamultiobj.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%   - Carga el paquete v96q más reciente.
%   - Copia logs/tables/report/mat a una carpeta temporal corta.
%   - Genera ZIP desde rutas relativas.
%   - Verifica el ZIP descomprimiéndolo y contando archivos.
%   - Copia el ZIP reparado al paquete original y a una carpeta fix1.
%
% Uso:
%   fix = repair_report_package_zip_v96q_fix1();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar paquete v96q más reciente
    % ---------------------------------------------------------------------
    pkgBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_results_report_package_v96q');

    if ~isfolder(pkgBaseDir)
        error('No existe pkgBaseDir: %s', pkgBaseDir);
    end

    d = dir(pkgBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró paquete v96q.');
    end

    [~,idxPkg] = max([d.datenum]);
    pkgDirPrev = fullfile(pkgBaseDir,d(idxPkg).name);

    logsDirPrev = fullfile(pkgDirPrev,'logs');
    tablesDirPrev = fullfile(pkgDirPrev,'tables');
    reportDirPrev = fullfile(pkgDirPrev,'report');
    matDirPrev = fullfile(pkgDirPrev,'mat');
    packageDirPrev = fullfile(pkgDirPrev,'package');

    pkgMatPrev = fullfile(matDirPrev,'TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.mat');

    if ~isfile(pkgMatPrev)
        error('No existe MAT v96q: %s', pkgMatPrev);
    end

    S = load(pkgMatPrev);

    if ~strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_PASS")
        error('El paquete v96q no está en PASS. Diagnosis: %s', string(S.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida fix1
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    fixBaseDir = fullfile(rootDir,'05_runs','report_package_zip_repair_v96q_fix1');
    fixDir = fullfile(fixBaseDir,['REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1_' timestamp]);

    logsDir = fullfile(fixDir,'logs');
    tablesDir = fullfile(fixDir,'tables');
    matDir = fullfile(fixDir,'mat');
    packageDir = fullfile(fixDir,'package');

    if ~isfolder(fixBaseDir), mkdir(fixBaseDir); end
    if ~isfolder(fixDir), mkdir(fixDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(packageDir), mkdir(packageDir); end
    if ~isfolder(packageDirPrev), mkdir(packageDirPrev); end

    % ---------------------------------------------------------------------
    % Verificar carpetas fuente
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96qfix1("logs", logsDirPrev, isfolder(logsDirPrev), "Original logs folder.");
    sourceRows{end+1,1} = local_source_row_v96qfix1("tables", tablesDirPrev, isfolder(tablesDirPrev), "Original tables folder.");
    sourceRows{end+1,1} = local_source_row_v96qfix1("report", reportDirPrev, isfolder(reportDirPrev), "Original report folder.");
    sourceRows{end+1,1} = local_source_row_v96qfix1("mat", matDirPrev, isfolder(matDirPrev), "Original mat folder.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    source_folders_ok = all(Tsource.exists);

    if ~source_folders_ok
        error('Faltan carpetas fuente del paquete v96q.');
    end

    % ---------------------------------------------------------------------
    % Crear staging corto en tempdir
    % ---------------------------------------------------------------------
    stagingRoot = fullfile(tempdir, ['v96qfix1_' timestamp]);
    if isfolder(stagingRoot)
        rmdir(stagingRoot,'s');
    end
    mkdir(stagingRoot);

    stagingPayload = fullfile(stagingRoot,'payload');
    mkdir(stagingPayload);

    copyfile(logsDirPrev, fullfile(stagingPayload,'logs'));
    copyfile(tablesDirPrev, fullfile(stagingPayload,'tables'));
    copyfile(reportDirPrev, fullfile(stagingPayload,'report'));
    copyfile(matDirPrev, fullfile(stagingPayload,'mat'));

    % No incluir zips previos dentro del payload.
    local_delete_zips_recursive_v96qfix1(stagingPayload);

    payloadFiles = local_list_files_recursive_v96qfix1(stagingPayload);
    nPayloadFiles = numel(payloadFiles);

    if nPayloadFiles < 5
        error('Payload demasiado pequeño; archivos encontrados: %d', nPayloadFiles);
    end

    % ---------------------------------------------------------------------
    % Crear ZIP desde rutas relativas
    % ---------------------------------------------------------------------
    repairedZipName = ['TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_FIX1_' timestamp '.zip'];
    repairedZipTemp = fullfile(stagingRoot,repairedZipName);

    oldDir = pwd;
    cleanupObj = onCleanup(@() cd(oldDir));

    cd(stagingPayload);
    zip(repairedZipTemp, {'logs','tables','report','mat'});
    cd(oldDir);

    zip_created_temp = isfile(repairedZipTemp);

    if ~zip_created_temp
        error('No se creó ZIP temporal reparado.');
    end

    % ---------------------------------------------------------------------
    % Verificar ZIP por descompresión
    % ---------------------------------------------------------------------
    verifyDir = fullfile(stagingRoot,'verify_unzip');
    if isfolder(verifyDir)
        rmdir(verifyDir,'s');
    end
    mkdir(verifyDir);

    unzip(repairedZipTemp, verifyDir);

    verifiedFiles = local_list_files_recursive_v96qfix1(verifyDir);
    nVerifiedFiles = numel(verifiedFiles);

    requiredNames = [ ...
        "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.md"
        "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.txt"
        "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q.mat"
        "RESULTS_TEXT_BASE_v96q.md"
        "TECHNICAL_DICTUM_v96q.md"
        "MANUSCRIPT_CAVEATS_v96q.md"
        "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_recommended_solution.csv"
        "TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_v96q_executive_summary.csv" ];

    requiredPresent = false(numel(requiredNames),1);

    verifiedNames = strings(numel(verifiedFiles),1);
    for i = 1:numel(verifiedFiles)
        [~,nm,ext] = fileparts(verifiedFiles{i});
        verifiedNames(i) = string(nm) + string(ext);
    end

    for i = 1:numel(requiredNames)
        requiredPresent(i) = any(verifiedNames == requiredNames(i));
    end

    required_all_present = all(requiredPresent);

    % ---------------------------------------------------------------------
    % Copiar ZIP reparado a salida fix1 y al paquete original
    % ---------------------------------------------------------------------
    repairedZipFix = fullfile(packageDir,repairedZipName);
    repairedZipOriginalPackage = fullfile(packageDirPrev,repairedZipName);

    copyfile(repairedZipTemp, repairedZipFix);
    copyfile(repairedZipTemp, repairedZipOriginalPackage);

    zip_created_fix = isfile(repairedZipFix);
    zip_created_original_package = isfile(repairedZipOriginalPackage);

    % ---------------------------------------------------------------------
    % Tabla de contenido verificado
    % ---------------------------------------------------------------------
    contentRows = {};
    for i = 1:numel(verifiedFiles)
        rel = erase(string(verifiedFiles{i}), string(verifyDir) + filesep);
        info = dir(verifiedFiles{i});

        row = struct();
        row.item = rel;
        row.bytes = info.bytes;
        contentRows{end+1,1} = row; %#ok<AGROW>
    end

    TzipContent = struct2table(vertcat(contentRows{:}));

    requiredRows = {};
    for i = 1:numel(requiredNames)
        row = struct();
        row.required_file = requiredNames(i);
        row.present = requiredPresent(i);
        requiredRows{end+1,1} = row; %#ok<AGROW>
    end

    Trequired = struct2table(vertcat(requiredRows{:}));

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF01", ...
        "Original package v96q loaded", ...
        true, ...
        string(pkgMatPrev), ...
        "Must load latest v96q MAT.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF02", ...
        "Original package v96q PASS", ...
        strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_PASS"), ...
        string(S.diagnosis), ...
        "Original package must be PASS.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF03", ...
        "Source folders available", ...
        source_folders_ok, ...
        sprintf("folders available=%d of %d", sum(Tsource.exists), height(Tsource)), ...
        "logs/tables/report/mat must exist.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF04", ...
        "Payload copied to short staging path", ...
        nPayloadFiles >= 5, ...
        sprintf("payload files=%d; staging=%s", nPayloadFiles, stagingPayload), ...
        "Payload must contain report files before zipping.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF05", ...
        "ZIP created from relative paths", ...
        zip_created_temp, ...
        string(repairedZipTemp), ...
        "ZIP must be created in short staging path.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF06", ...
        "ZIP verified by unzip", ...
        nVerifiedFiles >= nPayloadFiles*0.95, ...
        sprintf("verified files=%d; payload files=%d", nVerifiedFiles, nPayloadFiles), ...
        "Unzipped file count must approximately match payload.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF07", ...
        "Required files present in ZIP", ...
        required_all_present, ...
        sprintf("required present=%d of %d", sum(requiredPresent), numel(requiredPresent)), ...
        "Core report files must be present in repaired ZIP.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF08", ...
        "ZIP copied to fix and original package folders", ...
        zip_created_fix && zip_created_original_package, ...
        sprintf("fix=%d; original_package=%d", zip_created_fix, zip_created_original_package), ...
        "Repaired ZIP must be accessible from fix folder and original package folder.");

    checks{end+1,1} = local_check_row_v96qfix1( ...
        "QF09", ...
        "No GA executed", ...
        true, ...
        "This repair script does not call gamultiobj.", ...
        "ZIP repair must not rerun optimization.");

    Tchecks = struct2table(vertcat(checks{:}));

    repair_pass = all(Tchecks.pass);

    if repair_pass
        diagnosis = "REPORT_PACKAGE_ZIP_REPAIR_PASS";
        decision = "REPAIRED_ZIP_VERIFIED_AND_READY";
        next_step = "9.6r — FINAL-RESULTS-ARCHIVE-AND-MANUSCRIPT-READY-CHECK-001";
    else
        diagnosis = "REPORT_PACKAGE_ZIP_REPAIR_REQUIRES_REVIEW";
        decision = "REVIEW_REPAIRED_ZIP_CONTENTS";
        next_step = "Review failed checks.";
    end

    repairFlags = struct();
    repairFlags.original_package_loaded = true;
    repairFlags.original_package_pass = strcmp(string(S.diagnosis),"TRIOBJECTIVE_FORMAL_RESULTS_REPORT_PACKAGE_PASS");
    repairFlags.no_GA_executed = true;
    repairFlags.no_sources_modified = true;
    repairFlags.source_folders_ok = source_folders_ok;
    repairFlags.nPayloadFiles = nPayloadFiles;
    repairFlags.zip_created_temp = zip_created_temp;
    repairFlags.nVerifiedFiles = nVerifiedFiles;
    repairFlags.required_all_present = required_all_present;
    repairFlags.zip_created_fix = zip_created_fix;
    repairFlags.zip_created_original_package = zip_created_original_package;
    repairFlags.repaired_zip_fix = string(repairedZipFix);
    repairFlags.repaired_zip_original_package = string(repairedZipOriginalPackage);
    repairFlags.zip_repair_completed = repair_pass;

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outSourceCsv = fullfile(tablesDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1_source_folders.csv');
    outZipContentCsv = fullfile(tablesDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1_zip_content.csv');
    outRequiredCsv = fullfile(tablesDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1_required_files.csv');
    outChecksCsv = fullfile(tablesDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1_checks.csv');

    writetable(Tsource,outSourceCsv);
    writetable(TzipContent,outZipContentCsv);
    writetable(Trequired,outRequiredCsv);
    writetable(Tchecks,outChecksCsv);

    outMd = fullfile(logsDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1.md');
    outTxt = fullfile(logsDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1.txt');
    outMat = fullfile(matDir,'REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step','repairFlags', ...
        'Tsource','TzipContent','Trequired','Tchecks', ...
        'pkgDirPrev','pkgMatPrev','fixDir','stagingRoot','stagingPayload', ...
        'repairedZipTemp','repairedZipFix','repairedZipOriginalPackage', ...
        'outMd','outTxt','outMat','outSourceCsv','outZipContentCsv','outRequiredCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Paquete original\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', pkgDirPrev);

    fprintf(fid,'## ZIP reparado\n\n');
    fprintf(fid,'ZIP en carpeta fix1:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', repairedZipFix);

    fprintf(fid,'ZIP copiado al paquete original:\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', repairedZipOriginalPackage);

    fprintf(fid,'## Verificación\n\n');
    fprintf(fid,'| Campo | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| payload_files | %d |\n', nPayloadFiles);
    fprintf(fid,'| verified_files_after_unzip | %d |\n', nVerifiedFiles);
    fprintf(fid,'| required_files_present | %d de %d |\n', sum(requiredPresent), numel(requiredPresent));
    fprintf(fid,'| zip_created_fix | %d |\n', zip_created_fix);
    fprintf(fid,'| zip_created_original_package | %d |\n\n', zip_created_original_package);

    fprintf(fid,'## Archivos requeridos\n\n');
    fprintf(fid,'| Archivo | Presente |\n');
    fprintf(fid,'|---|---:|\n');

    for i = 1:height(Trequired)
        fprintf(fid,'| `%s` | %d |\n', ...
            string(Trequired.required_file(i)), ...
            Trequired.present(i));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia | Criterio |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tchecks.id(i)), ...
            string(Tchecks.check(i)), ...
            Tchecks.pass(i), ...
            string(Tchecks.evidence(i)), ...
            string(Tchecks.criterion(i)));
    end

    fprintf(fid,'\n## Dictamen\n\n');
    if repair_pass
        fprintf(fid,'El ZIP fue reparado usando una ruta temporal corta y rutas relativas. El archivo fue descomprimido y verificado. Este ZIP reemplaza al ZIP previo no confiable generado por v96q.\n');
    else
        fprintf(fid,'La reparación del ZIP requiere revisión. Ver checks fallidos.\n');
    end

    fclose(fid);

    % TXT
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'REPORT-PACKAGE-ZIP-REPAIR-001\n');
    fprintf(fid,'status: REPORT_PACKAGE_ZIP_REPAIR_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'decision: %s\n', decision);
    fprintf(fid,'next_step: %s\n', next_step);
    fprintf(fid,'original_package_loaded: %d\n', repairFlags.original_package_loaded);
    fprintf(fid,'original_package_pass: %d\n', repairFlags.original_package_pass);
    fprintf(fid,'no_GA_executed: %d\n', repairFlags.no_GA_executed);
    fprintf(fid,'no_sources_modified: %d\n', repairFlags.no_sources_modified);
    fprintf(fid,'source_folders_ok: %d\n', repairFlags.source_folders_ok);
    fprintf(fid,'nPayloadFiles: %d\n', repairFlags.nPayloadFiles);
    fprintf(fid,'zip_created_temp: %d\n', repairFlags.zip_created_temp);
    fprintf(fid,'nVerifiedFiles: %d\n', repairFlags.nVerifiedFiles);
    fprintf(fid,'required_all_present: %d\n', repairFlags.required_all_present);
    fprintf(fid,'zip_created_fix: %d\n', repairFlags.zip_created_fix);
    fprintf(fid,'zip_created_original_package: %d\n', repairFlags.zip_created_original_package);
    fprintf(fid,'zip_repair_completed: %d\n', repairFlags.zip_repair_completed);
    fprintf(fid,'repaired_zip_fix: %s\n', repairFlags.repaired_zip_fix);
    fprintf(fid,'repaired_zip_original_package: %s\n', repairFlags.repaired_zip_original_package);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Consola
    % ---------------------------------------------------------------------
    fix = struct();
    fix.status = 'REPORT_PACKAGE_ZIP_REPAIR_COMPLETED';
    fix.diagnosis = diagnosis;
    fix.decision = decision;
    fix.next_step = next_step;
    fix.repairFlags = repairFlags;
    fix.Tsource = Tsource;
    fix.Trequired = Trequired;
    fix.TzipContent = TzipContent;
    fix.Tchecks = Tchecks;
    fix.fixDir = fixDir;
    fix.outMd = outMd;
    fix.outTxt = outTxt;
    fix.outMat = outMat;
    fix.repairedZipFix = repairedZipFix;
    fix.repairedZipOriginalPackage = repairedZipOriginalPackage;

    disp('=== REPORT_PACKAGE_ZIP_REPAIR_v96q_fix1 ===')
    disp(fix.status)
    disp('=== DIAGNOSIS ===')
    disp(fix.diagnosis)
    disp('=== DECISION ===')
    disp(fix.decision)
    disp('=== NEXT STEP ===')
    disp(fix.next_step)
    disp('=== REPAIR FLAGS ===')
    disp(fix.repairFlags)
    disp('=== REQUIRED FILES ===')
    disp(fix.Trequired)
    disp('=== CHECKS ===')
    disp(fix.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(fix.outMd)
    disp(fix.outTxt)
    disp(fix.outMat)
    disp(fix.repairedZipFix)
    disp(fix.repairedZipOriginalPackage)

end

% =========================================================================
% Helpers
% =========================================================================

function row = local_source_row_v96qfix1(name, folderPath, existsFlag, note)
    row = struct();
    row.name = string(name);
    row.folder = string(folderPath);
    row.exists = logical(existsFlag);
    row.note = string(note);
end

function row = local_check_row_v96qfix1(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function files = local_list_files_recursive_v96qfix1(folderPath)
    files = {};

    if ~isfolder(folderPath)
        return
    end

    d = dir(folderPath);

    for i = 1:numel(d)
        name = d(i).name;

        if strcmp(name,'.') || strcmp(name,'..') || strcmp(name,'.MATLABDriveTag')
            continue
        end

        fp = fullfile(folderPath,name);

        if d(i).isdir
            sub = local_list_files_recursive_v96qfix1(fp);
            files = [files, sub]; %#ok<AGROW>
        else
            files{end+1} = fp; %#ok<AGROW>
        end
    end
end

function local_delete_zips_recursive_v96qfix1(folderPath)
    if ~isfolder(folderPath)
        return
    end

    d = dir(folderPath);

    for i = 1:numel(d)
        name = d(i).name;

        if strcmp(name,'.') || strcmp(name,'..') || strcmp(name,'.MATLABDriveTag')
            continue
        end

        fp = fullfile(folderPath,name);

        if d(i).isdir
            local_delete_zips_recursive_v96qfix1(fp);
        else
            [~,~,ext] = fileparts(fp);
            if strcmpi(ext,'.zip')
                delete(fp);
            end
        end
    end
end