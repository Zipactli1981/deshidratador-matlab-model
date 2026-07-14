%% patch_master_nomenclature_draft_v96z.m
% 9.6z-draft-f
% MASTER-NOMENCLATURE-DRAFT-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Draft # 10. Nomenclature in MASTER_manuscript_v01.md.
%
% Scope:
%   1. Replace #10 Nomenclature content.
%   2. Update #10 status to DRAFT_READY_FOR_REVIEW.
%   3. Include symbols and abbreviations used in the manuscript.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if hard structural prechecks fail.
%   - Does not modify #1--#9, #11, or #12.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER NOMENCLATURE DRAFT v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_NOMENCLATURE_DRAFT_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_NOMENCLATURE_DRAFT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_NOMENCLATURE_DRAFT_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_nomenclature_draft_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MND-PRE-01', 'MASTER exists', exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_NOMENCLATURE_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = normalizeNewlines(fileread(masterPath));
Tchecks = addCheck(Tchecks, 'MND-PRE-02', 'MASTER readable', strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

Headings = detectCleanHeadings(txt);
Tchecks = addCheck(Tchecks, 'MND-PRE-03', 'Route-B order valid before Nomenclature draft', isRouteBOrderValid(Headings), routeBEvidence(Headings));

idxNom = findHeadingExact(Headings, '# 10. Nomenclature');
idxRefs = findHeadingExact(Headings, '# 11. References');

Tchecks = addCheck(Tchecks, 'MND-PRE-04', '# 10 Nomenclature exists once', numel(idxNom) == 1, headingSummary(Headings, idxNom));
Tchecks = addCheck(Tchecks, 'MND-PRE-05', '# 11 References exists once', numel(idxRefs) == 1, headingSummary(Headings, idxRefs));

nomBefore = sectionSegmentByHeading(txt, Headings, '# 10. Nomenclature');
refsBefore = sectionSegmentByHeading(txt, Headings, '# 11. References');
refsSigBefore = simpleTextSignature(refsBefore);

Tchecks = addCheck(Tchecks, 'MND-PRE-06', 'Nomenclature status precheck informational', true, ...
    sprintf('pending=%d draftReady=%d', contains(string(nomBefore),'`STATUS: PENDING`'), contains(string(nomBefore),'`STATUS: DRAFT_READY_FOR_REVIEW`')));

hardPrecheckIds = ["MND-PRE-01","MND-PRE-02","MND-PRE-03","MND-PRE-04","MND-PRE-05"];
preFailed = Tchecks(~Tchecks.pass & ismember(Tchecks.id, hardPrecheckIds), :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_NOMENCLATURE_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_STRUCTURAL_PRECHECK_FAILED', ...
        'Structural precheck failed.');
end

nomBlock = [
"# 10. Nomenclature" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"## Symbols" newline newline ...
"- `m_dot`: air mass flow rate used as an operational decision variable, kg/s." newline ...
"- `MR`: moisture ratio; terminal drying-performance indicator used for feasibility assessment." newline ...
"- `Q_aux`: auxiliary thermal energy demand assigned to the LPG heating system, kWh." newline ...
"- `r_rec`: air recirculation ratio; fraction of outlet air returned to the process stream after recirculation starts." newline ...
"- `T_min`: minimum process-air temperature imposed by the operating policy, °C." newline ...
"- `t_rec_ini`: recirculation start time; time at which the recirculation branch is activated, h." newline ...
"- `CO2`: carbon dioxide equivalent indicator used in conditional environmental post-processing." newline newline ...
"## Abbreviations and labels" newline newline ...
"- `2-SAH`: two solar air heaters in series; collector-efficiency representation used in the sensitivity analysis." newline ...
"- `GA`: genetic algorithm." newline ...
"- `H2`: historical reference operating point retained for comparison; not a newly optimized R1 solution." newline ...
"- `LPG`: liquefied petroleum gas used by the auxiliary heating system." newline ...
"- `R1`: formal controlled optimization run used to generate the reported computed nondominated set." newline ...
"- `R1_solution_3`: selected balanced feasible R1 candidate." newline ...
"- `R1_solution_7`: selected energy-conservative feasible R1 candidate." newline ...
"- `R1_solution_9`: selected aggressive drying R1 candidate with higher auxiliary-energy demand." newline ...
"- `SAH`: solar air heater." newline newline ...
"## Interpretation notes" newline newline ...
"- The notation `computed nondominated set` refers to the numerical set obtained under the specified GA configuration, seed, decision-variable bounds, and model assumptions; it is not used as a claim of a complete global Pareto front." newline ...
"- Economic and CO2-related quantities remain conditional until final source-locked prices, tariffs, emission factors, regional scope, unit basis, source year, and conversion factors are fixed." newline ...
];

nomBlock = char(join(string(nomBlock), ''));

Tchecks = addCheck(Tchecks, 'MND-DRAFT-01', 'Draft contains required symbols', ...
    all([contains(string(nomBlock),'m_dot'), contains(string(nomBlock),'MR'), contains(string(nomBlock),'Q_aux'), contains(string(nomBlock),'r_rec'), contains(string(nomBlock),'T_min'), contains(string(nomBlock),'t_rec_ini')]), ...
    'm_dot/MR/Q_aux/r_rec/T_min/t_rec_ini');

Tchecks = addCheck(Tchecks, 'MND-DRAFT-02', 'Draft contains required abbreviations', ...
    all([contains(string(nomBlock),'2-SAH'), contains(string(nomBlock),'GA'), contains(string(nomBlock),'H2'), contains(string(nomBlock),'LPG'), contains(string(nomBlock),'R1'), contains(string(nomBlock),'SAH')]), ...
    '2-SAH/GA/H2/LPG/R1/SAH');

Tchecks = addCheck(Tchecks, 'MND-DRAFT-03', 'Draft avoids unsupported global claims', ...
    ~hasUnsupportedGlobalOptimumClaim(nomBlock) && ~hasUnsupportedGlobalParetoClaim(nomBlock), ...
    sprintf('globalOpt=%d globalPareto=%d', hasUnsupportedGlobalOptimumClaim(nomBlock), hasUnsupportedGlobalParetoClaim(nomBlock)));

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_NOMENCLATURE_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft check failed.');
end

workTxt = replaceSectionByHeading(txt, Headings, '# 10. Nomenclature', nomBlock);
HeadingsAfter = detectCleanHeadings(workTxt);
nomAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature');
refsAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References');
refsSigAfter = simpleTextSignature(refsAfter);

Tchecks = addCheck(Tchecks, 'MND-POST-01', 'Route-B order valid after Nomenclature reconstruction', isRouteBOrderValid(HeadingsAfter), routeBEvidence(HeadingsAfter));
Tchecks = addCheck(Tchecks, 'MND-POST-02', 'Nomenclature status updated', contains(string(nomAfter),'`STATUS: DRAFT_READY_FOR_REVIEW`'), sprintf('present=%d', contains(string(nomAfter),'`STATUS: DRAFT_READY_FOR_REVIEW`')));
Tchecks = addCheck(Tchecks, 'MND-POST-03', 'Nomenclature PENDING marker removed', ~contains(string(nomAfter),'`STATUS: PENDING`'), sprintf('present=%d', contains(string(nomAfter),'`STATUS: PENDING`')));
Tchecks = addCheck(Tchecks, 'MND-POST-04', 'References section preserved exactly', strcmp(refsBefore, refsAfter) && refsSigBefore == refsSigAfter, sprintf('beforeSig=%d afterSig=%d', refsSigBefore, refsSigAfter));
Tchecks = addCheck(Tchecks, 'MND-POST-05', 'No GA executed', true, 'Text-only Nomenclature draft');
Tchecks = addCheck(Tchecks, 'MND-POST-06', 'No drying model executed', true, 'Text-only Nomenclature draft');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_NOMENCLATURE_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

copyfile(masterPath, backupPath);
Tchecks = addCheck(Tchecks, 'MND-WRITE-01', 'Backup created before writing', exist(backupPath,'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_NOMENCLATURE_DRAFT_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end
fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MND-WRITE-02', 'MASTER updated', true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);
diagnosis = 'MASTER_NOMENCLATURE_DRAFT_PASS';
decision = 'MASTER_UPDATED_WITH_NOMENCLATURE_DRAFT';
writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, 'Nomenclature drafted with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_NOMENCLATURE_DRAFT_DONE\n');

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
            lineCol(end+1,1) = i; %#ok<AGROW>
            charCol(end+1,1) = lineStart(i); %#ok<AGROW>
            levelCol(end+1,1) = numel(tok{1}); %#ok<AGROW>
            rawCol(end+1,1) = string(li); %#ok<AGROW>
            titleCol(end+1,1) = string(strtrim(tok{2})); %#ok<AGROW>
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
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', Headings.line(ii), Headings.charpos(ii), Headings.level(ii), Headings.raw(ii));
    end
    s = join(parts, ' || ');
end

function segment = sectionSegmentByHeading(txt, Headings, rawHeading)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx), segment = ''; return; end
    i = idx(1);
    startPos = Headings.charpos(i);
    endPos = strlength(string(txt)) + 1;
    for j = i+1:height(Headings)
        if Headings.level(j) <= Headings.level(i)
            endPos = Headings.charpos(j);
            break;
        end
    end
    segment = char(extractBetween(string(txt), startPos, endPos-1));
end

function txtOut = replaceSectionByHeading(txt, Headings, rawHeading, newBlock)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx), error('Heading not found for replacement: %s', rawHeading); end
    i = idx(1);
    startPos = Headings.charpos(i);
    endPos = strlength(string(txt)) + 1;
    for j = i+1:height(Headings)
        if Headings.level(j) <= Headings.level(i)
            endPos = Headings.charpos(j);
            break;
        end
    end
    before = extractBefore(string(txt), startPos);
    after = extractAfter(string(txt), endPos-1);
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
    ev = sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', firstChar(Headings,idx7), firstChar(Headings,idxD), firstChar(Headings,idx8), firstChar(Headings,idx9), firstChar(Headings,idx10), firstChar(Headings,idx11), firstChar(Headings,idx12));
end

function sig = simpleTextSignature(txt)
    s = char(string(txt)); vals = double(s);
    if isempty(vals), sig = 0; else, weights = mod(1:numel(vals), 997) + 1; sig = mod(sum(vals(:)' .* weights), 2147483647); end
end

function present = hasUnsupportedGlobalOptimumClaim(txt)
    s = lower(string(normalizeNewlines(txt))); lines = splitlines(s); present = false;
    prohibited = ["global optimum","globally optimal","global optimality"];
    protective = ["do not","does not","no claim","not claim","not as","not be interpreted","should not","avoid","prohibited","restriction","instead of","proof of","not proof","no prohibited","not used as a claim"];
    for i=1:numel(lines)
        li = strtrim(lines(i)); hasBad = any(contains(li, prohibited)); if ~hasBad, continue; end
        if ~any(contains(li, protective)), present = true; return; end
    end
end

function present = hasUnsupportedGlobalParetoClaim(txt)
    s = lower(string(normalizeNewlines(txt))); lines = splitlines(s); present = false;
    prohibited = ["global pareto front","complete pareto front","complete pareto-front characterization"];
    protective = ["do not","does not","no claim","not claim","not as","not be interpreted","should not","avoid","prohibited","restriction","instead of","use computed nondominated set","no prohibited","not used as a claim"];
    for i=1:numel(lines)
        li = strtrim(lines(i)); hasBad = any(contains(li, prohibited)); if ~hasBad, continue; end
        if ~any(contains(li, protective)), present = true; return; end
    end
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid = fopen(outPath, 'w');
    fprintf(fid, 'MASTER HEADINGS DETECTED - NOMENCLATURE DRAFT AFTER\n\n');
    fprintf(fid, 'MASTER: %s\n\n', masterPath);
    for i=1:height(Headings)
        fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
    end
    fclose(fid);
end

function writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note);
    fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n', diagnosis, decision, note, reportPath, checksPath);
    fprintf('\nMASTER_NOMENCLATURE_DRAFT_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_NOMENCLATURE_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-NOMENCLATURE-DRAFT-v96z-001`\n\n');
    fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid, '## Decision\n\n`%s`\n\n', decision);
    fprintf(fid, '## Note\n\n`%s`\n\n', note);
    fprintf(fid, '## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid, '## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings after: `%s`\n\n', masterPath, backupPath, checksPath, headingsAfterPath);
    failed = Tchecks(~Tchecks.pass, :);
    fprintf(fid, '## Failed checks\n\n');
    if isempty(failed), fprintf(fid, 'None.\n\n');
    else
        fprintf(fid, '| id | check | evidence |\n|---|---|---|\n');
        for i=1:height(failed), fprintf(fid, '| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i)); end
        fprintf(fid, '\n');
    end
    fprintf(fid, '## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i=1:height(Tchecks), fprintf(fid, '| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i)); end
    fclose(fid);
end
