%% patch_master_references_scaffold_completion_v96z.m
% 9.6z-draft-g
% MASTER-REFERENCES-SCAFFOLD-COMPLETION-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Replace #11 References "Required references" scaffold with an honest
%   preliminary reference scaffold for review.
%
% Scope:
%   1. Replace #11 References content only.
%   2. Update #11 status to PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW.
%   3. Do not invent bibliographic metadata.
%   4. Keep references explicitly marked as placeholders pending source verification.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if hard structural prechecks fail.
%   - Does not modify #1--#10 or #12.
%   - Does not add in-text citations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER REFERENCES SCAFFOLD COMPLETION v96z ===\n');

rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

draftDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

backupPath = fullfile(draftDir, ...
    sprintf('MASTER_manuscript_v01_BEFORE_REFERENCES_SCAFFOLD_COMPLETION_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_REFERENCES_SCAFFOLD_COMPLETION_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_REFERENCES_SCAFFOLD_COMPLETION_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_references_scaffold_completion_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MRSC-PRE-01', 'MASTER exists', exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_REFERENCES_SCAFFOLD_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = normalizeNewlines(fileread(masterPath));
Tchecks = addCheck(Tchecks, 'MRSC-PRE-02', 'MASTER readable', strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

Headings = detectCleanHeadings(txt);
Tchecks = addCheck(Tchecks, 'MRSC-PRE-03', 'Route-B order valid before References scaffold completion', isRouteBOrderValid(Headings), routeBEvidence(Headings));

idxRefs = findHeadingExact(Headings, '# 11. References');
idxSupp = findHeadingExact(Headings, '# 12. Supplementary material');

Tchecks = addCheck(Tchecks, 'MRSC-PRE-04', '# 11 References exists once', numel(idxRefs) == 1, headingSummary(Headings, idxRefs));
Tchecks = addCheck(Tchecks, 'MRSC-PRE-05', '# 12 Supplementary material exists once', numel(idxSupp) == 1, headingSummary(Headings, idxSupp));

refsBefore = sectionSegmentByHeading(txt, Headings, '# 11. References');
suppBefore = sectionSegmentByHeading(txt, Headings, '# 12. Supplementary material');
suppSigBefore = simpleTextSignature(suppBefore);

Tchecks = addCheck(Tchecks, 'MRSC-PRE-06', 'References scaffold status informational', true, ...
    sprintf('pending=%d requiredRefs=%d', contains(string(refsBefore),'`STATUS: PENDING`'), contains(string(refsBefore),'Required references:')));

hardPrecheckIds = ["MRSC-PRE-01","MRSC-PRE-02","MRSC-PRE-03","MRSC-PRE-04","MRSC-PRE-05"];
preFailed = Tchecks(~Tchecks.pass & ismember(Tchecks.id, hardPrecheckIds), :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_REFERENCES_SCAFFOLD_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_STRUCTURAL_PRECHECK_FAILED', ...
        'Structural precheck failed.');
end

refsBlock = [
"# 11. References" newline newline ...
"`STATUS: PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW`" newline newline ...
"This section is a preliminary reference scaffold for internal manuscript review. The entries below are intentionally not formatted as final bibliographic records because source verification, DOI/URL retrieval, edition checking, and journal-style formatting have not yet been completed. No bibliographic metadata should be treated as final until the reference-verification step is performed." newline newline ...
"## Reference groups to verify before submission" newline newline ...
"- `[REF-DRYING-MODEL-01]` Foundational or project-specific source for the lumped dynamic drying model, including air temperature, product temperature, moisture-ratio evolution, and structural thermal response." newline ...
"- `[REF-SOLAR-AIR-HEATER-01]` Source for solar air-heater thermal-efficiency modeling and the collector-efficiency representation used in the baseline and sensitivity analyses." newline ...
"- `[REF-2SAH-01]` Source or internal derivation record supporting the two-solar-air-heaters-in-series, 2-SAH, efficiency curve used in the collector-efficiency sensitivity." newline ...
"- `[REF-MULTIOBJECTIVE-GA-01]` Source for the multiobjective genetic-algorithm method and interpretation of computed nondominated sets." newline ...
"- `[REF-DRYING-QUALITY-01]` Source supporting the final moisture-ratio feasibility threshold, MR <= 0.1, or its product-specific interpretation." newline ...
"- `[REF-LPG-ENERGY-01]` Source for LPG lower heating value, unit conversion, fuel-price basis, or auxiliary-energy cost conversion used in post-processing." newline ...
"- `[REF-EMISSIONS-CO2-01]` Source for CO2 emission factors and unit-basis assumptions used in conditional environmental post-processing." newline ...
"- `[REF-THESIS-H2-01]` Historical thesis or internal project document supporting the H2 reference operating point and its interpretation as a historical baseline rather than an R1-optimized solution." newline newline ...
"## Verification requirements" newline newline ...
"- Replace each placeholder with a complete, verified bibliographic record before submission." newline ...
"- Insert corresponding in-text citations only after each reference has been verified." newline ...
"- Confirm consistency between citation style, reference style, DOI/URL availability, and journal requirements." newline ...
"- Do not treat cost or CO2 claims as final until fuel price, tariff, emission-factor, source-year, regional scope, unit-basis, and conversion assumptions are source-locked." newline ...
];

refsBlock = char(join(string(refsBlock), ''));

Tchecks = addCheck(Tchecks, 'MRSC-DRAFT-01', 'Draft removes Required references wording', ...
    ~contains(string(refsBlock), 'Required references:'), ...
    sprintf('present=%d', contains(string(refsBlock), 'Required references:')));

Tchecks = addCheck(Tchecks, 'MRSC-DRAFT-02', 'Draft keeps preliminary reference status honest', ...
    contains(string(refsBlock), 'PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW') && contains(lower(string(refsBlock)), 'not formatted as final bibliographic records'), ...
    sprintf('status=%d disclaimer=%d', contains(string(refsBlock), 'PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW'), contains(lower(string(refsBlock)), 'not formatted as final bibliographic records')));

Tchecks = addCheck(Tchecks, 'MRSC-DRAFT-03', 'Draft contains reference placeholder groups', ...
    all([contains(string(refsBlock),'REF-DRYING-MODEL-01'), contains(string(refsBlock),'REF-SOLAR-AIR-HEATER-01'), contains(string(refsBlock),'REF-MULTIOBJECTIVE-GA-01'), contains(string(refsBlock),'REF-EMISSIONS-CO2-01')]), ...
    'core reference placeholders');

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_REFERENCES_SCAFFOLD_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft check failed.');
end

workTxt = replaceSectionByHeading(txt, Headings, '# 11. References', refsBlock);
HeadingsAfter = detectCleanHeadings(workTxt);
refsAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References');
suppAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 12. Supplementary material');
suppSigAfter = simpleTextSignature(suppAfter);

Tchecks = addCheck(Tchecks, 'MRSC-POST-01', 'Route-B order valid after References reconstruction', isRouteBOrderValid(HeadingsAfter), routeBEvidence(HeadingsAfter));
Tchecks = addCheck(Tchecks, 'MRSC-POST-02', 'References status updated', contains(string(refsAfter),'`STATUS: PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW`'), sprintf('present=%d', contains(string(refsAfter),'`STATUS: PRELIMINARY_REFERENCE_SCAFFOLD_READY_FOR_REVIEW`')));
Tchecks = addCheck(Tchecks, 'MRSC-POST-03', 'References PENDING marker removed', ~contains(string(refsAfter),'`STATUS: PENDING`'), sprintf('present=%d', contains(string(refsAfter),'`STATUS: PENDING`')));
Tchecks = addCheck(Tchecks, 'MRSC-POST-04', 'Required references scaffold removed', ~contains(string(refsAfter),'Required references:'), sprintf('present=%d', contains(string(refsAfter),'Required references:')));
Tchecks = addCheck(Tchecks, 'MRSC-POST-05', 'Supplementary material preserved exactly', strcmp(suppBefore, suppAfter) && suppSigBefore == suppSigAfter, sprintf('beforeSig=%d afterSig=%d', suppSigBefore, suppSigAfter));
Tchecks = addCheck(Tchecks, 'MRSC-POST-06', 'No GA executed', true, 'Text-only References scaffold completion');
Tchecks = addCheck(Tchecks, 'MRSC-POST-07', 'No drying model executed', true, 'Text-only References scaffold completion');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_REFERENCES_SCAFFOLD_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

copyfile(masterPath, backupPath);
Tchecks = addCheck(Tchecks, 'MRSC-WRITE-01', 'Backup created before writing', exist(backupPath,'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_REFERENCES_SCAFFOLD_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end
fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MRSC-WRITE-02', 'MASTER updated', true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);
diagnosis = 'MASTER_REFERENCES_SCAFFOLD_COMPLETION_PASS';
decision = 'MASTER_UPDATED_WITH_REFERENCES_SCAFFOLD_COMPLETION';
writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, 'References scaffold completed with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_REFERENCES_SCAFFOLD_COMPLETION_DONE\n');

%% Local functions
function T = addCheck(T,id,check,pass,evidence)
    if isempty(pass), passScalar = false; else, passScalar = all(logical(pass(:))); end
    if ischar(evidence), evidenceScalar = string(evidence);
    elseif isstring(evidence), evidenceScalar = strjoin(evidence(:).', ' | ');
    else, evidenceScalar = string(evidence); end
    T = [T; table(string(id), string(check), logical(passScalar), string(evidenceScalar), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function txt = normalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
end

function Headings = detectCleanHeadings(txt)
    txt = normalizeNewlines(txt);
    lines = splitlines(string(txt));
    nLines = numel(lines);
    lineStart = zeros(nLines,1);
    pos = 1;
    for i = 1:nLines
        lineStart(i) = pos;
        pos = pos + strlength(lines(i)) + 1;
    end
    lineCol = []; charCol = []; levelCol = [];
    rawCol = strings(0,1); titleCol = strings(0,1);
    for i = 1:nLines
        li = char(lines(i));
        tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            lineCol(end+1,1)=i; %#ok<AGROW>
            charCol(end+1,1)=lineStart(i); %#ok<AGROW>
            levelCol(end+1,1)=numel(tok{1}); %#ok<AGROW>
            rawCol(end+1,1)=string(li); %#ok<AGROW>
            titleCol(end+1,1)=string(strtrim(tok{2})); %#ok<AGROW>
        end
    end
    Headings = table(lineCol, charCol, levelCol, rawCol, titleCol, ...
        'VariableNames', {'line','charpos','level','raw','title'});
end

function idx = findHeadingExact(Headings, rawHeading)
    idx = find(strcmp(strtrim(Headings.raw), strtrim(string(rawHeading))));
end

function p = firstChar(Headings, idx)
    if isempty(idx), p = NaN; else, p = Headings.charpos(idx(1)); end
end

function s = headingSummary(Headings, idx)
    if isempty(idx), s = "NOT_DETECTED"; return; end
    parts = strings(numel(idx),1);
    for k=1:numel(idx)
        ii=idx(k); parts(k)=sprintf('line=%d char=%d level=%d raw=%s', Headings.line(ii), Headings.charpos(ii), Headings.level(ii), Headings.raw(ii));
    end
    s = join(parts, ' || ');
end

function segment = sectionSegmentByHeading(txt, Headings, rawHeading)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx), segment = ''; return; end
    i=idx(1); startPos=Headings.charpos(i); endPos=strlength(string(txt))+1;
    for j=i+1:height(Headings)
        if Headings.level(j) <= Headings.level(i)
            endPos = Headings.charpos(j); break;
        end
    end
    segment = char(extractBetween(string(txt), startPos, endPos-1));
end

function txtOut = replaceSectionByHeading(txt, Headings, rawHeading, newBlock)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx), error('Heading not found for replacement: %s', rawHeading); end
    i=idx(1); startPos=Headings.charpos(i); endPos=strlength(string(txt))+1;
    for j=i+1:height(Headings)
        if Headings.level(j) <= Headings.level(i)
            endPos = Headings.charpos(j); break;
        end
    end
    before=extractBefore(string(txt), startPos);
    after=extractAfter(string(txt), endPos-1);
    txtOut = char(before + string(newBlock) + newline + after);
end

function tf = isRouteBOrderValid(Headings)
    idx7=findHeadingExact(Headings,'# 7. Results and discussion'); idxD=findHeadingExact(Headings,'## 7.5 Discussion');
    idx8=findHeadingExact(Headings,'# 8. Limitations'); idx9=findHeadingExact(Headings,'# 9. Conclusions');
    idx10=findHeadingExact(Headings,'# 10. Nomenclature'); idx11=findHeadingExact(Headings,'# 11. References'); idx12=findHeadingExact(Headings,'# 12. Supplementary material');
    pos=[firstChar(Headings,idx7), firstChar(Headings,idxD), firstChar(Headings,idx8), firstChar(Headings,idx9), firstChar(Headings,idx10), firstChar(Headings,idx11), firstChar(Headings,idx12)];
    tf = all(~isnan(pos)) && all(diff(pos) > 0);
end

function ev = routeBEvidence(Headings)
    idx7=findHeadingExact(Headings,'# 7. Results and discussion'); idxD=findHeadingExact(Headings,'## 7.5 Discussion');
    idx8=findHeadingExact(Headings,'# 8. Limitations'); idx9=findHeadingExact(Headings,'# 9. Conclusions');
    idx10=findHeadingExact(Headings,'# 10. Nomenclature'); idx11=findHeadingExact(Headings,'# 11. References'); idx12=findHeadingExact(Headings,'# 12. Supplementary material');
    ev=sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', firstChar(Headings,idx7), firstChar(Headings,idxD), firstChar(Headings,idx8), firstChar(Headings,idx9), firstChar(Headings,idx10), firstChar(Headings,idx11), firstChar(Headings,idx12));
end

function sig = simpleTextSignature(txt)
    s=char(string(txt)); vals=double(s);
    if isempty(vals), sig=0; else, weights=mod(1:numel(vals),997)+1; sig=mod(sum(vals(:)' .* weights),2147483647); end
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid=fopen(outPath,'w');
    fprintf(fid,'MASTER HEADINGS DETECTED - REFERENCES SCAFFOLD COMPLETION AFTER\n\n');
    fprintf(fid,'MASTER: %s\n\n', masterPath);
    for i=1:height(Headings)
        fprintf(fid,'%04d | line %05d | char %08d | level %d | %s\n', i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
    end
    fclose(fid);
end

function writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note);
    fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n', diagnosis, decision, note, reportPath, checksPath);
    fprintf('\nMASTER_REFERENCES_SCAFFOLD_COMPLETION_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    fid=fopen(reportPath,'w');
    fprintf(fid,'# MASTER_REFERENCES_SCAFFOLD_COMPLETION_v96z report\n\n');
    fprintf(fid,'## Identifier\n\n`MASTER-REFERENCES-SCAFFOLD-COMPLETION-v96z-001`\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n', decision);
    fprintf(fid,'## Note\n\n`%s`\n\n', note);
    fprintf(fid,'## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings after: `%s`\n\n', masterPath, backupPath, checksPath, headingsAfterPath);
    failed=Tchecks(~Tchecks.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if isempty(failed), fprintf(fid,'None.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n|---|---|---|\n');
        for i=1:height(failed), fprintf(fid,'| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i)); end
        fprintf(fid,'\n');
    end
    fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i=1:height(Tchecks), fprintf(fid,'| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i)); end
    fclose(fid);
end
