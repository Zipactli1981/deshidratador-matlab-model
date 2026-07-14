function fixout = fix_manuscript_results_section_traceability_v96t_fix1()
% FIX_MANUSCRIPT_RESULTS_SECTION_TRACEABILITY_v96t_fix1
% 9.6t-fix1 — MANUSCRIPT-DRAFT-ZIP-TRACEABILITY-FIX-001
%
% Objetivo:
%   Corregir la trazabilidad del borrador v96t para reconocer el ZIP fix2
%   validado del paquete v96s.
%
% Este script:
%   - NO ejecuta GA.
%   - NO llama modelo.
%   - NO llama función objetivo.
%   - NO recalcula resultados.
%   - NO modifica fuentes protegidas.
%   - Solo valida el ZIP fix2 y actualiza el estado del borrador v96t.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Localizar borrador v96t más reciente
    % ---------------------------------------------------------------------
    draftBaseDir = fullfile(rootDir,'05_runs','manuscript_results_section_draft_v96t');

    if ~isfolder(draftBaseDir)
        error('No existe draftBaseDir: %s', draftBaseDir);
    end

    d = dir(draftBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró borrador v96t.');
    end

    [~,idxDraft] = max([d.datenum]);
    draftDir = fullfile(draftBaseDir,d(idxDraft).name);

    draftMat = fullfile(draftDir,'mat','MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t.mat');

    if ~isfile(draftMat)
        error('No existe MAT v96t: %s', draftMat);
    end

    D = load(draftMat);

    % ---------------------------------------------------------------------
    % Localizar paquete v96s usado por el borrador
    % ---------------------------------------------------------------------
    if isfield(D,'pkgDir')
        pkgDir = string(D.pkgDir);
    else
        error('El MAT v96t no contiene pkgDir.');
    end

    if ~isfolder(pkgDir)
        error('No existe pkgDir declarado en v96t: %s', pkgDir);
    end

    % ---------------------------------------------------------------------
    % Localizar MAT fix2
    % ---------------------------------------------------------------------
    fix2Dir = fullfile(pkgDir,'package','zip_repair_fix2');
    fix2Mat = fullfile(fix2Dir,'FINAL_RESULTS_PACKAGE_ZIP_REPAIR_v96s_fix2.mat');

    if ~isfile(fix2Mat)
        error('No existe MAT fix2: %s', fix2Mat);
    end

    Z = load(fix2Mat);

    if ~isfield(Z,'diagnosis')
        error('El MAT fix2 no contiene diagnosis.');
    end

    fix2Diagnosis = string(Z.diagnosis);

    if ~isfield(Z,'finalZipPath')
        error('El MAT fix2 no contiene finalZipPath.');
    end

    finalZipPath = string(Z.finalZipPath);

    if ~isfield(Z,'finalZipSizeBytes')
        error('El MAT fix2 no contiene finalZipSizeBytes.');
    end

    finalZipSizeBytes = Z.finalZipSizeBytes;

    if ~isfield(Z,'expectedCount') || ~isfield(Z,'verifiedCount')
        error('El MAT fix2 no contiene expectedCount/verifiedCount.');
    end

    if ~isfield(Z,'expectedTotalSizeBytes') || ~isfield(Z,'verifiedTotalSizeBytes')
        error('El MAT fix2 no contiene expectedTotalSizeBytes/verifiedTotalSizeBytes.');
    end

    expectedCount = Z.expectedCount;
    verifiedCount = Z.verifiedCount;
    expectedTotalSizeBytes = Z.expectedTotalSizeBytes;
    verifiedTotalSizeBytes = Z.verifiedTotalSizeBytes;

    zipExists = isfile(finalZipPath);
    zipSizePlausible = finalZipSizeBytes > 100000;
    diagnosisPass = strcmp(fix2Diagnosis,"FINAL_RESULTS_PACKAGE_ZIP_REPAIR_FIX2_PASS");
    countPass = expectedCount == verifiedCount;
    sizePass = expectedTotalSizeBytes == verifiedTotalSizeBytes;

    fix2Verified = diagnosisPass && zipExists && zipSizePlausible && countPass && sizePass;

    % ---------------------------------------------------------------------
    % Cargar checks previos y corregir T03
    % ---------------------------------------------------------------------
    Tchecks = D.Tchecks;

    idxT03 = find(string(Tchecks.id)=="T03",1,'first');

    if isempty(idxT03)
        error('No se encontró check T03 en Tchecks.');
    end

    Tchecks.pass(idxT03) = fix2Verified;
    Tchecks.evidence(idxT03) = string(finalZipPath);

    % ---------------------------------------------------------------------
    % Recalcular diagnóstico del borrador
    % ---------------------------------------------------------------------
    draft_pass = all(Tchecks.pass);

    if draft_pass
        diagnosis = "MANUSCRIPT_RESULTS_SECTION_DRAFT_PASS";
        decision = "RESULTS_SECTION_DRAFT_READY_FOR_REVIEW";
        next_step = "Review wording, figure captions and manuscript caveats.";
    else
        diagnosis = "MANUSCRIPT_RESULTS_SECTION_DRAFT_REQUIRES_REVIEW";
        decision = "REVIEW_FAILED_DRAFT_CHECKS";
        next_step = "Review failed checks before using the draft.";
    end

    % ---------------------------------------------------------------------
    % Carpeta fix1
    % ---------------------------------------------------------------------
    fixDir = fullfile(draftDir,'traceability_fix1');
    logsDir = fullfile(fixDir,'logs');
    tablesDir = fullfile(fixDir,'tables');
    matDir = fullfile(fixDir,'mat');

    mkdir_if_needed(fixDir);
    mkdir_if_needed(logsDir);
    mkdir_if_needed(tablesDir);
    mkdir_if_needed(matDir);

    % ---------------------------------------------------------------------
    % Tabla de trazabilidad ZIP
    % ---------------------------------------------------------------------
    TzipTrace = table();
    TzipTrace.metric = [ ...
        "fix2_diagnosis"; ...
        "zip_exists"; ...
        "zip_size_bytes"; ...
        "expected_count"; ...
        "verified_count"; ...
        "expected_total_size_bytes"; ...
        "verified_total_size_bytes"; ...
        "fix2_verified"];
    TzipTrace.value = [ ...
        string(fix2Diagnosis); ...
        string(zipExists); ...
        string(finalZipSizeBytes); ...
        string(expectedCount); ...
        string(verifiedCount); ...
        string(expectedTotalSizeBytes); ...
        string(verifiedTotalSizeBytes); ...
        string(fix2Verified)];

    outZipTraceCsv = fullfile(tablesDir,'MANUSCRIPT_RESULTS_SECTION_v96t_fix1_zip_traceability.csv');
    writetable(TzipTrace,outZipTraceCsv);

    outChecksCsv = fullfile(tablesDir,'MANUSCRIPT_RESULTS_SECTION_v96t_fix1_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Crear MD de cierre
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_fix1.md');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD fix1: %s', outMd);
    end

    fprintf(fid,'# MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_fix1\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Decisión: `%s`\n\n', decision);
    fprintf(fid,'Siguiente paso: `%s`\n\n', next_step);

    fprintf(fid,'## Corrección aplicada\n\n');
    fprintf(fid,'Se corrigió la trazabilidad automática del ZIP fix2. ');
    fprintf(fid,'No se modificaron resultados, figuras ni texto del manuscrito.\n\n');

    fprintf(fid,'## ZIP fix2 validado\n\n');
    fprintf(fid,'- Diagnosis fix2: `%s`\n', fix2Diagnosis);
    fprintf(fid,'- ZIP: `%s`\n', finalZipPath);
    fprintf(fid,'- ZIP existe: `%d`\n', zipExists);
    fprintf(fid,'- Tamaño ZIP: `%d` bytes\n', finalZipSizeBytes);
    fprintf(fid,'- Archivos esperados: `%d`\n', expectedCount);
    fprintf(fid,'- Archivos verificados: `%d`\n', verifiedCount);
    fprintf(fid,'- Tamaño esperado: `%d` bytes\n', expectedTotalSizeBytes);
    fprintf(fid,'- Tamaño verificado: `%d` bytes\n', verifiedTotalSizeBytes);
    fprintf(fid,'- fix2Verified: `%d`\n\n', fix2Verified);

    fprintf(fid,'## Checks corregidos\n\n');
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
    if draft_pass
        fprintf(fid,'El borrador v96t queda aprobado. El único fallo previo era trazabilidad automática del ZIP fix2, ya corregida.\n');
    else
        fprintf(fid,'El borrador v96t aún requiere revisión porque quedan checks fallidos.\n');
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % Guardar MAT fix1
    % ---------------------------------------------------------------------
    outMat = fullfile(matDir,'MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_fix1.mat');

    save(outMat, ...
        'diagnosis','decision','next_step', ...
        'draftDir','draftMat','pkgDir','fix2Dir','fix2Mat', ...
        'fix2Diagnosis','finalZipPath','finalZipSizeBytes', ...
        'expectedCount','verifiedCount','expectedTotalSizeBytes','verifiedTotalSizeBytes', ...
        'zipExists','zipSizePlausible','diagnosisPass','countPass','sizePass','fix2Verified', ...
        'Tchecks','TzipTrace', ...
        'fixDir','outMd','outMat','outChecksCsv','outZipTraceCsv');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    fixout = struct();
    fixout.status = 'MANUSCRIPT_RESULTS_SECTION_DRAFT_FIX1_COMPLETED';
    fixout.diagnosis = diagnosis;
    fixout.decision = decision;
    fixout.next_step = next_step;

    fixout.draftDir = draftDir;
    fixout.draftMat = draftMat;
    fixout.fix2Mat = fix2Mat;
    fixout.finalZipPath = finalZipPath;
    fixout.finalZipSizeBytes = finalZipSizeBytes;
    fixout.fix2Verified = fix2Verified;

    fixout.TzipTrace = TzipTrace;
    fixout.Tchecks = Tchecks;

    fixout.outMd = outMd;
    fixout.outMat = outMat;

    disp('=== MANUSCRIPT_RESULTS_SECTION_DRAFT_v96t_fix1 ===')
    disp(fixout.status)
    disp('=== DIAGNOSIS ===')
    disp(fixout.diagnosis)
    disp('=== DECISION ===')
    disp(fixout.decision)
    disp('=== NEXT STEP ===')
    disp(fixout.next_step)
    disp('=== ZIP TRACE ===')
    disp(fixout.TzipTrace)
    disp('=== CHECKS ===')
    disp(fixout.Tchecks)
    disp('=== FIX MD ===')
    disp(fixout.outMd)

end

% =========================================================================
% Helpers
% =========================================================================

function mkdir_if_needed(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end