function zfix = repair_final_results_package_zip_v96s_fix1()
% REPAIR_FINAL_RESULTS_PACKAGE_ZIP_v96s_fix1
% 9.6s-fix1 — FINAL-RESULTS-PACKAGE-ZIP-REPAIR-001
%
% Objetivo:
%   Reparar el ZIP del paquete final v96s.
%
% Contexto:
%   El paquete v96s generó correctamente resultados, tablas, figuras,
%   README y dictamen, pero MATLAB emitió warnings al crear el ZIP usando
%   rutas relativas. El ZIP quedó creado, pero probablemente incompleto.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO modifica fuentes protegidas.
%   - NO regenera resultados.
%   - Solo reconstruye el ZIP desde rutas absolutas verificadas.
%
% Uso:
%   zfix = repair_final_results_package_zip_v96s_fix1();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar paquete v96s más reciente
    % ---------------------------------------------------------------------
    pkgBaseDir = fullfile(rootDir,'05_runs','final_results_package_with_fig4_v96s');

    if ~isfolder(pkgBaseDir)
        error('No existe pkgBaseDir: %s', pkgBaseDir);
    end

    d = dir(pkgBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró paquete v96s.');
    end

    [~,idxPkg] = max([d.datenum]);
    pkgDir = fullfile(pkgBaseDir,d(idxPkg).name);

    pkgMat = fullfile(pkgDir,'mat','FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s.mat');

    if ~isfile(pkgMat)
        error('No existe MAT v96s: %s', pkgMat);
    end

    P = load(pkgMat);

    if ~strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS")
        error('El paquete v96s no está en PASS. Diagnosis: %s', string(P.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Rutas esperadas del paquete
    % ---------------------------------------------------------------------
    mdDir = fullfile(pkgDir,'md');
    txtDir = fullfile(pkgDir,'txt');
    tablesDir = fullfile(pkgDir,'tables');
    figuresDir = fullfile(pkgDir,'figures');
    pngDir = fullfile(figuresDir,'png');
    pdfDir = fullfile(figuresDir,'pdf');
    figNativeDir = fullfile(figuresDir,'fig');
    matDir = fullfile(pkgDir,'mat');

    packageDir = fullfile(pkgDir,'package');
    repairDir = fullfile(packageDir,'zip_repair_fix1');
    repairPayloadDir = fullfile(repairDir,'payload');
    repairZipDir = fullfile(repairDir,'zip');
    logsDir = fullfile(repairDir,'logs');
    tablesRepairDir = fullfile(repairDir,'tables');

    mkdir_if_needed(packageDir);
    mkdir_if_needed(repairDir);
    mkdir_if_needed(repairPayloadDir);
    mkdir_if_needed(repairZipDir);
    mkdir_if_needed(logsDir);
    mkdir_if_needed(tablesRepairDir);

    % ---------------------------------------------------------------------
    % Recolectar archivos fuente absolutos
    % ---------------------------------------------------------------------
    requiredFiles = strings(0,1);

    requiredFiles(end+1,1) = string(fullfile(mdDir,'README_FINAL_RESULTS_PACKAGE_v96s.md'));
    requiredFiles(end+1,1) = string(fullfile(mdDir,'FINAL_RESULTS_PACKAGE_v96s_TECHNICAL_DICTUM.md'));
    requiredFiles(end+1,1) = string(fullfile(mdDir,'FORMAL_RESULTS_NARRATIVE_v96r.md'));

    requiredFiles(end+1,1) = string(fullfile(txtDir,'README_FINAL_RESULTS_PACKAGE_v96s.txt'));
    requiredFiles(end+1,1) = string(fullfile(txtDir,'FINAL_RESULTS_PACKAGE_v96s_TECHNICAL_DICTUM.txt'));
    requiredFiles(end+1,1) = string(fullfile(txtDir,'FORMAL_RESULTS_NARRATIVE_v96r.txt'));

    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_all_formal_solutions.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_key_solutions_H1_H2_H4_H9.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_narrative_summary.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_narrative_checks.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_final_summary.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_checks.csv'));
    requiredFiles(end+1,1) = string(fullfile(tablesDir,'FINAL_RESULTS_PACKAGE_v96s_checks_FINAL.csv'));

    requiredFiles(end+1,1) = string(fullfile(matDir,'FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s.mat'));

    pngFiles = local_list_files(pngDir,'*.png');
    pdfFiles = local_list_files(pdfDir,'*.pdf');
    figFiles = local_list_files(figNativeDir,'*.fig');

    requiredFiles = [requiredFiles; pngFiles; pdfFiles; figFiles];

    % Quitar duplicados preservando orden
    requiredFiles = unique(requiredFiles,'stable');

    existsMask = false(size(requiredFiles));
    fileSizeBytes = zeros(size(requiredFiles));

    for i = 1:numel(requiredFiles)
        existsMask(i) = isfile(requiredFiles(i));
        if existsMask(i)
            info = dir(requiredFiles(i));
            if ~isempty(info)
                fileSizeBytes(i) = info.bytes;
            end
        end
    end

    Tsource = table();
    Tsource.source_file = requiredFiles;
    Tsource.exists = existsMask;
    Tsource.size_bytes = fileSizeBytes;

    outSourceCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1_source_files.csv');
    writetable(Tsource,outSourceCsv);

    missingFiles = requiredFiles(~existsMask);

    if ~isempty(missingFiles)
        disp('=== MISSING FILES ===')
        disp(missingFiles)
        error('Hay archivos requeridos inexistentes. No se crea ZIP.');
    end

    % ---------------------------------------------------------------------
    % Construir payload limpio con subcarpetas controladas
    % ---------------------------------------------------------------------
    payloadMdDir = fullfile(repairPayloadDir,'md');
    payloadTxtDir = fullfile(repairPayloadDir,'txt');
    payloadTablesDir = fullfile(repairPayloadDir,'tables');
    payloadMatDir = fullfile(repairPayloadDir,'mat');
    payloadFiguresDir = fullfile(repairPayloadDir,'figures');
    payloadPngDir = fullfile(payloadFiguresDir,'png');
    payloadPdfDir = fullfile(payloadFiguresDir,'pdf');
    payloadFigDir = fullfile(payloadFiguresDir,'fig');

    mkdir_if_needed(payloadMdDir);
    mkdir_if_needed(payloadTxtDir);
    mkdir_if_needed(payloadTablesDir);
    mkdir_if_needed(payloadMatDir);
    mkdir_if_needed(payloadFiguresDir);
    mkdir_if_needed(payloadPngDir);
    mkdir_if_needed(payloadPdfDir);
    mkdir_if_needed(payloadFigDir);

    copiedFiles = strings(0,1);

    for i = 1:numel(requiredFiles)
        src = requiredFiles(i);
        [~,~,ext] = fileparts(char(src));

        srcChar = char(src);

        if contains(srcChar,[filesep 'md' filesep])
            dstDir = payloadMdDir;
        elseif contains(srcChar,[filesep 'txt' filesep])
            dstDir = payloadTxtDir;
        elseif contains(srcChar,[filesep 'tables' filesep])
            dstDir = payloadTablesDir;
        elseif contains(srcChar,[filesep 'mat' filesep])
            dstDir = payloadMatDir;
        elseif strcmpi(ext,'.png')
            dstDir = payloadPngDir;
        elseif strcmpi(ext,'.pdf')
            dstDir = payloadPdfDir;
        elseif strcmpi(ext,'.fig')
            dstDir = payloadFigDir;
        else
            dstDir = repairPayloadDir;
        end

        dst = fullfile(dstDir,local_filename(src));
        copyfile(src,dst);

        copiedFiles(end+1,1) = string(dst); %#ok<AGROW>
    end

    % ---------------------------------------------------------------------
    % Verificar payload antes de comprimir
    % ---------------------------------------------------------------------
    payloadFiles = local_recursive_files(repairPayloadDir);

    payloadExists = false(size(payloadFiles));
    payloadSizeBytes = zeros(size(payloadFiles));

    for i = 1:numel(payloadFiles)
        payloadExists(i) = isfile(payloadFiles(i));
        if payloadExists(i)
            info = dir(payloadFiles(i));
            if ~isempty(info)
                payloadSizeBytes(i) = info.bytes;
            end
        end
    end

    Tpayload = table();
    Tpayload.payload_file = payloadFiles;
    Tpayload.exists = payloadExists;
    Tpayload.size_bytes = payloadSizeBytes;

    outPayloadCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1_payload_files.csv');
    writetable(Tpayload,outPayloadCsv);

    if ~all(payloadExists)
        error('No todos los archivos del payload existen.');
    end

    if any(payloadSizeBytes == 0)
        warning('Hay archivos de payload con tamaño cero. Revisar tabla de payload.');
    end

    % ---------------------------------------------------------------------
    % Crear ZIP usando rutas absolutas, sin cd a payload
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    zipName = ['FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_FIX1_' timestamp '.zip'];
    zipPath = fullfile(repairZipDir,zipName);

    % zip con rutas absolutas: evita warnings por rutas relativas en MATLAB Drive
    zip(zipPath,cellstr(payloadFiles));

    zip_created = isfile(zipPath);

    if zip_created
        zipInfo = dir(zipPath);
        zipSizeBytes = zipInfo.bytes;
    else
        zipSizeBytes = 0;
    end

    % ---------------------------------------------------------------------
    % Verificación por unzip temporal
    % ---------------------------------------------------------------------
    verifyDir = fullfile(repairDir,'verify_unzipped');
    if isfolder(verifyDir)
        try
            rmdir(verifyDir,'s');
        catch
        end
    end
    mkdir_if_needed(verifyDir);

    unzip_ok = false;
    verifiedFiles = strings(0,1);
    verifiedCount = 0;
    verifiedSizeBytes = 0;

    try
        unzip(zipPath,verifyDir);
        unzip_ok = true;
        verifiedFiles = local_recursive_files(verifyDir);
        verifiedCount = numel(verifiedFiles);

        for i = 1:numel(verifiedFiles)
            info = dir(verifiedFiles(i));
            if ~isempty(info)
                verifiedSizeBytes = verifiedSizeBytes + info.bytes;
            end
        end
    catch ME
        unzip_ok = false;
        verifiedFiles = strings(0,1);
        warning('No se pudo verificar por unzip: %s', ME.message);
    end

    % Como zip con rutas absolutas puede incluir estructura de ruta absoluta,
    % la verificación principal será número de archivos y tamaño total.
    expectedCount = numel(payloadFiles);
    expectedTotalSizeBytes = sum(payloadSizeBytes);

    verified_count_ok = verifiedCount == expectedCount;
    verified_size_ok = verifiedSizeBytes == expectedTotalSizeBytes;

    % ---------------------------------------------------------------------
    % Tablas de verificación
    % ---------------------------------------------------------------------
    Tverify = table();
    Tverify.metric = [ ...
        "expected_payload_count"; ...
        "verified_unzipped_count"; ...
        "expected_payload_total_size_bytes"; ...
        "verified_unzipped_total_size_bytes"; ...
        "zip_size_bytes"];
    Tverify.value = [ ...
        expectedCount; ...
        verifiedCount; ...
        expectedTotalSizeBytes; ...
        verifiedSizeBytes; ...
        zipSizeBytes];

    outVerifyCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1_verification.csv');
    writetable(Tverify,outVerifyCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("ZF01","Latest v96s package loaded",true,string(pkgMat));
    checks{end+1,1} = check_row("ZF02","v96s package diagnosis PASS",strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS"),string(P.diagnosis));
    checks{end+1,1} = check_row("ZF03","All required source files exist",all(existsMask),sprintf("nRequired=%d",numel(requiredFiles)));
    checks{end+1,1} = check_row("ZF04","PNG files present",numel(pngFiles)>=3,sprintf("nPNG=%d",numel(pngFiles)));
    checks{end+1,1} = check_row("ZF05","PDF files present",numel(pdfFiles)>=3,sprintf("nPDF=%d",numel(pdfFiles)));
    checks{end+1,1} = check_row("ZF06","FIG files present",numel(figFiles)>=3,sprintf("nFIG=%d",numel(figFiles)));
    checks{end+1,1} = check_row("ZF07","Payload copied",numel(payloadFiles)==numel(requiredFiles),sprintf("payload=%d; required=%d",numel(payloadFiles),numel(requiredFiles)));
    checks{end+1,1} = check_row("ZF08","ZIP created",zip_created,string(zipPath));
    checks{end+1,1} = check_row("ZF09","ZIP nonempty",zipSizeBytes>0,sprintf("zipSizeBytes=%d",zipSizeBytes));
    checks{end+1,1} = check_row("ZF10","ZIP unzip verification ok",unzip_ok,sprintf("verifyDir=%s",verifyDir));
    checks{end+1,1} = check_row("ZF11","Verified file count matches payload",verified_count_ok,sprintf("verified=%d; expected=%d",verifiedCount,expectedCount));
    checks{end+1,1} = check_row("ZF12","Verified total size matches payload",verified_size_ok,sprintf("verifiedSize=%d; expectedSize=%d",verifiedSizeBytes,expectedTotalSizeBytes));
    checks{end+1,1} = check_row("ZF13","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("ZF14","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("ZF15","No sources modified",true,"Only package repair directories written.");

    Tchecks = struct2table(vertcat(checks{:}));

    repair_pass = all(Tchecks.pass);

    if repair_pass
        diagnosis = "FINAL_RESULTS_PACKAGE_ZIP_REPAIR_PASS";
        decision = "REPAIRED_FINAL_RESULTS_ZIP_VERIFIED";
        next_step = "9.6t — MANUSCRIPT-RESULTS-SECTION-DRAFT-001";
    else
        diagnosis = "FINAL_RESULTS_PACKAGE_ZIP_REPAIR_REQUIRES_REVIEW";
        decision = "REVIEW_ZIP_REPAIR_CHECKS";
        next_step = "Review failed checks before manuscript drafting.";
    end

    outChecksCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Markdown de reparación
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD de reparación: %s', outMd);
    end

    fprintf(fid,'# FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Paquete reparado\n\n');
    fprintf(fid,'- Paquete fuente: `%s`\n', pkgDir);
    fprintf(fid,'- ZIP reparado: `%s`\n', zipPath);
    fprintf(fid,'- Tamaño ZIP: `%d` bytes\n', zipSizeBytes);
    fprintf(fid,'- Payload esperado: `%d` archivos\n', expectedCount);
    fprintf(fid,'- Archivos verificados por unzip: `%d`\n', verifiedCount);
    fprintf(fid,'- Tamaño total payload: `%d` bytes\n', expectedTotalSizeBytes);
    fprintf(fid,'- Tamaño total verificado: `%d` bytes\n\n', verifiedSizeBytes);

    fprintf(fid,'## Tablas generadas\n\n');
    fprintf(fid,'- Source files: `%s`\n', outSourceCsv);
    fprintf(fid,'- Payload files: `%s`\n', outPayloadCsv);
    fprintf(fid,'- Verification: `%s`\n', outVerifyCsv);
    fprintf(fid,'- Checks: `%s`\n\n', outChecksCsv);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | `%s` |\n', ...
            string(Tchecks.id(i)), ...
            string(Tchecks.check(i)), ...
            Tchecks.pass(i), ...
            string(Tchecks.evidence(i)));
    end

    fprintf(fid,'\n## Dictamen\n\n');
    if repair_pass
        fprintf(fid,'El ZIP final fue reconstruido y verificado mediante descompresión temporal. Este ZIP debe sustituir al ZIP generado en 9.6s.\n');
    else
        fprintf(fid,'La reparación del ZIP requiere revisión. No usar el ZIP hasta resolver los checks fallidos.\n');
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(repairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'pkgDir','pkgMat','requiredFiles','Tsource','Tpayload','Tverify','Tchecks', ...
        'repairDir','repairPayloadDir','repairZipDir','verifyDir', ...
        'payloadFiles','zipPath','zip_created','zipSizeBytes', ...
        'unzip_ok','verifiedFiles','verifiedCount','verifiedSizeBytes', ...
        'expectedCount','expectedTotalSizeBytes', ...
        'verified_count_ok','verified_size_ok', ...
        'outSourceCsv','outPayloadCsv','outVerifyCsv','outChecksCsv','outMd','outMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    zfix = struct();
    zfix.status = 'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_COMPLETED';
    zfix.diagnosis = diagnosis;
    zfix.decision = decision;
    zfix.next_step = next_step;

    zfix.pkgDir = pkgDir;
    zfix.repairDir = repairDir;
    zfix.repairPayloadDir = repairPayloadDir;
    zfix.repairZipDir = repairZipDir;
    zfix.verifyDir = verifyDir;

    zfix.zipPath = zipPath;
    zfix.zipSizeBytes = zipSizeBytes;
    zfix.expectedCount = expectedCount;
    zfix.verifiedCount = verifiedCount;
    zfix.expectedTotalSizeBytes = expectedTotalSizeBytes;
    zfix.verifiedSizeBytes = verifiedSizeBytes;

    zfix.Tverify = Tverify;
    zfix.Tchecks = Tchecks;
    zfix.outMd = outMd;
    zfix.outMat = outMat;

    disp('=== FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix1 ===')
    disp(zfix.status)
    disp('=== DIAGNOSIS ===')
    disp(zfix.diagnosis)
    disp('=== DECISION ===')
    disp(zfix.decision)
    disp('=== NEXT STEP ===')
    disp(zfix.next_step)
    disp('=== ZIP ===')
    disp(zfix.zipPath)
    disp('=== ZIP SIZE BYTES ===')
    disp(zfix.zipSizeBytes)
    disp('=== VERIFY ===')
    disp(zfix.Tverify)
    disp('=== CHECKS ===')
    disp(zfix.Tchecks)
    disp('=== REPAIR MD ===')
    disp(zfix.outMd)

end

% =========================================================================
% Helpers
% =========================================================================

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end

function files = local_list_files(folderPath,pattern)
    files = strings(0,1);

    if ~isfolder(folderPath)
        return
    end

    d = dir(fullfile(folderPath,pattern));
    d = d(~[d.isdir]);

    for i = 1:numel(d)
        files(end+1,1) = string(fullfile(folderPath,d(i).name)); %#ok<AGROW>
    end
end

function name = local_filename(filePath)
    [~,n,e] = fileparts(char(filePath));
    name = [n e];
end

function files = local_recursive_files(folderPath)
    files = strings(0,1);

    d = dir(folderPath);

    for i = 1:numel(d)
        name = d(i).name;

        if strcmp(name,'.') || strcmp(name,'..') || strcmp(name,'.MATLABDriveTag')
            continue
        end

        p = fullfile(folderPath,name);

        if d(i).isdir
            sub = local_recursive_files(p);
            files = [files; sub]; %#ok<AGROW>
        else
            files(end+1,1) = string(p); %#ok<AGROW>
        end
    end
end

function row = check_row(id, checkName, passVal, evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end