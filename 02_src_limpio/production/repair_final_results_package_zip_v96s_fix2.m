function zfix = repair_final_results_package_zip_v96s_fix2()
% REPAIR_FINAL_RESULTS_PACKAGE_ZIP_v96s_fix2
% 9.6s-fix2 — FINAL-RESULTS-PACKAGE-ZIP-REPAIR-SHORTPATH-001
%
% Objetivo:
%   Reparar definitivamente el ZIP del paquete final v96s evitando
%   la función zip() de MATLAB sobre rutas largas de MATLAB Drive.
%
% Estrategia:
%   1. Localiza el paquete v96s más reciente.
%   2. Recolecta archivos requeridos.
%   3. Copia todo a una carpeta corta en tempdir.
%   4. Comprime con PowerShell Compress-Archive.
%   5. Descomprime y verifica número/tamaño de archivos.
%   6. Copia el ZIP verificado de regreso al paquete v96s.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO modifica fuentes protegidas.
%   - Solo repara ZIP.

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
    repairDir = fullfile(packageDir,'zip_repair_fix2');
    repairZipDir = fullfile(repairDir,'zip');
    logsDir = fullfile(repairDir,'logs');
    tablesRepairDir = fullfile(repairDir,'tables');

    mkdir_if_needed(packageDir);
    mkdir_if_needed(repairDir);
    mkdir_if_needed(repairZipDir);
    mkdir_if_needed(logsDir);
    mkdir_if_needed(tablesRepairDir);

    % ---------------------------------------------------------------------
    % Carpeta corta temporal
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    shortBaseDir = fullfile(tempdir,['v96s_zip_fix2_' timestamp]);
    shortPayloadDir = fullfile(shortBaseDir,'payload');
    shortZipDir = fullfile(shortBaseDir,'zip');
    shortVerifyDir = fullfile(shortBaseDir,'verify');

    if isfolder(shortBaseDir)
        rmdir(shortBaseDir,'s');
    end

    mkdir_if_needed(shortBaseDir);
    mkdir_if_needed(shortPayloadDir);
    mkdir_if_needed(shortZipDir);
    mkdir_if_needed(shortVerifyDir);

    payloadMdDir = fullfile(shortPayloadDir,'md');
    payloadTxtDir = fullfile(shortPayloadDir,'txt');
    payloadTablesDir = fullfile(shortPayloadDir,'tables');
    payloadMatDir = fullfile(shortPayloadDir,'mat');
    payloadFiguresDir = fullfile(shortPayloadDir,'figures');
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

    % ---------------------------------------------------------------------
    % Recolectar archivos requeridos
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
    requiredFiles = unique(requiredFiles,'stable');

    existsMask = false(size(requiredFiles));
    sourceSizeBytes = zeros(size(requiredFiles));

    for i = 1:numel(requiredFiles)
        existsMask(i) = isfile(requiredFiles(i));
        if existsMask(i)
            info = dir(requiredFiles(i));
            if ~isempty(info)
                sourceSizeBytes(i) = info.bytes;
            end
        end
    end

    Tsource = table();
    Tsource.source_file = requiredFiles;
    Tsource.exists = existsMask;
    Tsource.size_bytes = sourceSizeBytes;

    outSourceCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2_source_files.csv');
    writetable(Tsource,outSourceCsv);

    if ~all(existsMask)
        disp(requiredFiles(~existsMask))
        error('Faltan archivos fuente. No se puede construir ZIP.');
    end

    % ---------------------------------------------------------------------
    % Copiar a payload corto
    % ---------------------------------------------------------------------
    copiedFiles = strings(0,1);

    for i = 1:numel(requiredFiles)
        src = requiredFiles(i);
        srcChar = char(src);
        [~,~,ext] = fileparts(srcChar);

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
            dstDir = shortPayloadDir;
        end

        dst = fullfile(dstDir,local_filename(src));
        copyfile(src,dst);
        copiedFiles(end+1,1) = string(dst); %#ok<AGROW>
    end

    payloadFiles = local_recursive_files(shortPayloadDir);

    payloadSizeBytes = zeros(size(payloadFiles));
    for i = 1:numel(payloadFiles)
        info = dir(payloadFiles(i));
        if ~isempty(info)
            payloadSizeBytes(i) = info.bytes;
        end
    end

    expectedCount = numel(payloadFiles);
    expectedTotalSizeBytes = sum(payloadSizeBytes);

    Tpayload = table();
    Tpayload.payload_file = payloadFiles;
    Tpayload.size_bytes = payloadSizeBytes;

    outPayloadCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2_payload_files.csv');
    writetable(Tpayload,outPayloadCsv);

    % ---------------------------------------------------------------------
    % Comprimir con PowerShell Compress-Archive
    % ---------------------------------------------------------------------
    zipName = ['FINAL_RESULTS_PACKAGE_WITH_FIG4_v96s_FIX2_' timestamp '.zip'];
    shortZipPath = fullfile(shortZipDir,zipName);

    psSource = fullfile(shortPayloadDir,'*');
    psCmd = sprintf(['powershell -NoProfile -ExecutionPolicy Bypass -Command ', ...
        '"Compress-Archive -Path ''%s'' -DestinationPath ''%s'' -Force"'], ...
        psSource, shortZipPath);

    [statusPS,cmdoutPS] = system(psCmd);

    zip_created_short = isfile(shortZipPath);

    if zip_created_short
        zipInfoShort = dir(shortZipPath);
        zipSizeBytesShort = zipInfoShort.bytes;
    else
        zipSizeBytesShort = 0;
    end

    % ---------------------------------------------------------------------
    % Verificar con PowerShell Expand-Archive
    % ---------------------------------------------------------------------
    psVerifyCmd = sprintf(['powershell -NoProfile -ExecutionPolicy Bypass -Command ', ...
        '"Expand-Archive -Path ''%s'' -DestinationPath ''%s'' -Force"'], ...
        shortZipPath, shortVerifyDir);

    [statusVerifyPS,cmdoutVerifyPS] = system(psVerifyCmd);

    verifiedFiles = local_recursive_files(shortVerifyDir);

    verifiedSizeBytes = zeros(size(verifiedFiles));
    for i = 1:numel(verifiedFiles)
        info = dir(verifiedFiles(i));
        if ~isempty(info)
            verifiedSizeBytes(i) = info.bytes;
        end
    end

    verifiedCount = numel(verifiedFiles);
    verifiedTotalSizeBytes = sum(verifiedSizeBytes);

    verified_count_ok = verifiedCount == expectedCount;
    verified_size_ok = verifiedTotalSizeBytes == expectedTotalSizeBytes;

    Tverify = table();
    Tverify.metric = [ ...
        "expected_payload_count"; ...
        "verified_unzipped_count"; ...
        "expected_payload_total_size_bytes"; ...
        "verified_unzipped_total_size_bytes"; ...
        "short_zip_size_bytes"; ...
        "powershell_compress_status"; ...
        "powershell_expand_status"];
    Tverify.value = [ ...
        expectedCount; ...
        verifiedCount; ...
        expectedTotalSizeBytes; ...
        verifiedTotalSizeBytes; ...
        zipSizeBytesShort; ...
        statusPS; ...
        statusVerifyPS];

    outVerifyCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2_verification.csv');
    writetable(Tverify,outVerifyCsv);

    % ---------------------------------------------------------------------
    % Copiar ZIP verificado a paquete v96s
    % ---------------------------------------------------------------------
    finalZipPath = fullfile(repairZipDir,zipName);

    if zip_created_short
        copyfile(shortZipPath,finalZipPath);
    end

    final_zip_created = isfile(finalZipPath);

    if final_zip_created
        finalZipInfo = dir(finalZipPath);
        finalZipSizeBytes = finalZipInfo.bytes;
    else
        finalZipSizeBytes = 0;
    end

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};
    checks{end+1,1} = check_row("ZF2_01","Latest v96s package loaded",true,string(pkgMat));
    checks{end+1,1} = check_row("ZF2_02","v96s package diagnosis PASS",strcmp(string(P.diagnosis),"FINAL_RESULTS_PACKAGE_WITH_FIG4_PASS"),string(P.diagnosis));
    checks{end+1,1} = check_row("ZF2_03","All required source files exist",all(existsMask),sprintf("nRequired=%d",numel(requiredFiles)));
    checks{end+1,1} = check_row("ZF2_04","PNG files present",numel(pngFiles)>=3,sprintf("nPNG=%d",numel(pngFiles)));
    checks{end+1,1} = check_row("ZF2_05","PDF files present",numel(pdfFiles)>=3,sprintf("nPDF=%d",numel(pdfFiles)));
    checks{end+1,1} = check_row("ZF2_06","FIG files present",numel(figFiles)>=3,sprintf("nFIG=%d",numel(figFiles)));
    checks{end+1,1} = check_row("ZF2_07","Short payload copied",expectedCount==numel(requiredFiles),sprintf("payload=%d; required=%d",expectedCount,numel(requiredFiles)));
    checks{end+1,1} = check_row("ZF2_08","PowerShell Compress-Archive succeeded",statusPS==0,string(cmdoutPS));
    checks{end+1,1} = check_row("ZF2_09","Short ZIP created",zip_created_short,string(shortZipPath));
    checks{end+1,1} = check_row("ZF2_10","Short ZIP has plausible size",zipSizeBytesShort>100000,sprintf("zipSizeBytes=%d",zipSizeBytesShort));
    checks{end+1,1} = check_row("ZF2_11","PowerShell Expand-Archive succeeded",statusVerifyPS==0,string(cmdoutVerifyPS));
    checks{end+1,1} = check_row("ZF2_12","Verified file count matches payload",verified_count_ok,sprintf("verified=%d; expected=%d",verifiedCount,expectedCount));
    checks{end+1,1} = check_row("ZF2_13","Verified total size matches payload",verified_size_ok,sprintf("verifiedSize=%d; expectedSize=%d",verifiedTotalSizeBytes,expectedTotalSizeBytes));
    checks{end+1,1} = check_row("ZF2_14","Final ZIP copied to package",final_zip_created,string(finalZipPath));
    checks{end+1,1} = check_row("ZF2_15","Final ZIP size plausible",finalZipSizeBytes>100000,sprintf("finalZipSizeBytes=%d",finalZipSizeBytes));
    checks{end+1,1} = check_row("ZF2_16","No GA executed",true,"No gamultiobj call.");
    checks{end+1,1} = check_row("ZF2_17","No mechanistic rerun",true,"No objective/model call.");
    checks{end+1,1} = check_row("ZF2_18","No sources modified",true,"Only package repair directories and tempdir written.");

    Tchecks = struct2table(vertcat(checks{:}));

    repair_pass = all(Tchecks.pass);

    if repair_pass
        diagnosis = "FINAL_RESULTS_PACKAGE_ZIP_REPAIR_FIX2_PASS";
        decision = "REPAIRED_FINAL_RESULTS_ZIP_VERIFIED";
        next_step = "9.6t — MANUSCRIPT-RESULTS-SECTION-DRAFT-001";
    else
        diagnosis = "FINAL_RESULTS_PACKAGE_ZIP_REPAIR_FIX2_REQUIRES_REVIEW";
        decision = "REVIEW_ZIP_REPAIR_FIX2_CHECKS";
        next_step = "Review failed checks before manuscript drafting.";
    end

    outChecksCsv = fullfile(tablesRepairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Estrategia\n\n');
    fprintf(fid,'Se evitó `zip()` de MATLAB. El payload fue copiado a una ruta corta temporal y comprimido con PowerShell `Compress-Archive`.\n\n');

    fprintf(fid,'## ZIP reparado\n\n');
    fprintf(fid,'- ZIP final: `%s`\n', finalZipPath);
    fprintf(fid,'- Tamaño ZIP final: `%d` bytes\n', finalZipSizeBytes);
    fprintf(fid,'- Archivos esperados: `%d`\n', expectedCount);
    fprintf(fid,'- Archivos verificados: `%d`\n', verifiedCount);
    fprintf(fid,'- Tamaño payload esperado: `%d` bytes\n', expectedTotalSizeBytes);
    fprintf(fid,'- Tamaño verificado: `%d` bytes\n\n', verifiedTotalSizeBytes);

    fprintf(fid,'## Tablas\n\n');
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
        fprintf(fid,'ZIP reparado y verificado. Este archivo sustituye al ZIP original de 9.6s y al intento fix1.\n');
    else
        fprintf(fid,'La reparación fix2 requiere revisión. No usar ZIP hasta resolver checks fallidos.\n');
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % Guardar MAT
    % ---------------------------------------------------------------------
    outMat = fullfile(repairDir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'pkgDir','pkgMat','requiredFiles','Tsource','Tpayload','Tverify','Tchecks', ...
        'shortBaseDir','shortPayloadDir','shortZipDir','shortVerifyDir', ...
        'repairDir','repairZipDir','logsDir','tablesRepairDir', ...
        'shortZipPath','finalZipPath','finalZipSizeBytes','zipSizeBytesShort', ...
        'expectedCount','verifiedCount','expectedTotalSizeBytes','verifiedTotalSizeBytes', ...
        'statusPS','cmdoutPS','statusVerifyPS','cmdoutVerifyPS', ...
        'outSourceCsv','outPayloadCsv','outVerifyCsv','outChecksCsv','outMd','outMat');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    zfix = struct();
    zfix.status = 'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_FIX2_COMPLETED';
    zfix.diagnosis = diagnosis;
    zfix.decision = decision;
    zfix.next_step = next_step;

    zfix.pkgDir = pkgDir;
    zfix.repairDir = repairDir;
    zfix.shortBaseDir = shortBaseDir;
    zfix.shortPayloadDir = shortPayloadDir;
    zfix.shortZipPath = shortZipPath;
    zfix.finalZipPath = finalZipPath;
    zfix.finalZipSizeBytes = finalZipSizeBytes;

    zfix.expectedCount = expectedCount;
    zfix.verifiedCount = verifiedCount;
    zfix.expectedTotalSizeBytes = expectedTotalSizeBytes;
    zfix.verifiedTotalSizeBytes = verifiedTotalSizeBytes;

    zfix.Tverify = Tverify;
    zfix.Tchecks = Tchecks;
    zfix.outMd = outMd;
    zfix.outMat = outMat;

    disp('=== FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2 ===')
    disp(zfix.status)
    disp('=== DIAGNOSIS ===')
    disp(zfix.diagnosis)
    disp('=== DECISION ===')
    disp(zfix.decision)
    disp('=== NEXT STEP ===')
    disp(zfix.next_step)
    disp('=== FINAL ZIP ===')
    disp(zfix.finalZipPath)
    disp('=== FINAL ZIP SIZE BYTES ===')
    disp(zfix.finalZipSizeBytes)
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

    if ~isfolder(folderPath)
        return
    end

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