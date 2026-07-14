%% patch_master_minor_editorial_cleanup_v96z.m
% 9.6z-cleanup-a
% MASTER-MINOR-EDITORIAL-CLEANUP-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Apply a small, controlled editorial cleanup to MASTER_manuscript_v01.md.
%
% Scope:
%   1. Correct the known awkward hybrid-vs-gas-LPG sentence.
%   2. Update # 7 Results and discussion status conservatively:
%      `STATUS: PARTIAL`
%      -> `STATUS: STRUCTURALLY_INTEGRATED_CONTENT_REVIEW_PENDING`
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not remove genuine PENDING markers.
%   - Does not remove scaffolding.
%   - Does not touch cost/CO2 caveats.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER MINOR EDITORIAL CLEANUP v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_MINOR_EDITORIAL_CLEANUP_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_MINOR_EDITORIAL_CLEANUP_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_MINOR_EDITORIAL_CLEANUP_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_minor_cleanup_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MINOR_EDITORIAL_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-03', 'Route-B order valid before cleanup', ...
    routeBOK, routeBEvidence(Headings));

oldHybridSentence = ['R1_solution_3 showed a 43.07% reduction, while For R1_solution_9, ' ...
    'Q_aux decreased from 1773.9 kWh in gas-LPG-only mode to 1218.4 kWh in hybrid mode, ' ...
    'corresponding to a 31.31% reduction. R1_solution_9 showed a lower relative reduction of 31.31%, ' ...
    'consistent with its more aggressive drying condition and higher auxiliary-energy demand.'];

newHybridSentence = ['For R1_solution_3, Q_aux decreased from 1270.6 kWh in gas-LPG-only mode to 723.36 kWh in hybrid mode, ' ...
    'corresponding to a 43.07% reduction. For R1_solution_9, Q_aux decreased from 1773.9 kWh in gas-LPG-only mode ' ...
    'to 1218.4 kWh in hybrid mode, corresponding to a 31.31% reduction. The lower relative reduction observed for ' ...
    'R1_solution_9 is consistent with its more aggressive drying condition and higher auxiliary-energy demand.'];

% The old sentence may be embedded after a preceding sentence. Detect the exact awkward substring.
awkwardNeedle = 'R1_solution_3 showed a 43.07% reduction, while For R1_solution_9';

nAwkward = countLiteral(txt, awkwardNeedle);

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-04', 'Awkward hybrid sentence exists exactly once', ...
    nAwkward == 1, sprintf('count=%d', nAwkward));

requiredNums = ["1270.6", "723.36", "43.07", "1773.9", "1218.4", "31.31"];
numsPresent = true;
numEvidence = strings(numel(requiredNums),1);

for k = 1:numel(requiredNums)
    c = countLiteral(txt, char(requiredNums(k)));
    numEvidence(k) = sprintf('%s=%d', requiredNums(k), c);
    if c == 0
        numsPresent = false;
    end
end

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-05', 'Required numeric values present before cleanup', ...
    numsPresent, join(numEvidence, ' | '));

sec7StatusPattern = "# 7. Results and discussion" + newline + newline + "`STATUS: PARTIAL`";
nSec7Status = countLiteral(txt, char(sec7StatusPattern));

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-06', '# 7 STATUS: PARTIAL exists exactly once', ...
    nSec7Status == 1, sprintf('count=%d', nSec7Status));

pendingSectionsBefore = [
    countLiteral(txt, '# 1. Abstract')
    countLiteral(txt, '# 2. Keywords')
    countLiteral(txt, '# 3. Introduction')
    countLiteral(txt, '# 4. System description')
    countLiteral(txt, '# 5. Mathematical model')
    countLiteral(txt, '# 10. Nomenclature')
    countLiteral(txt, '# 11. References')
];

Tchecks = addCheck(Tchecks, 'MCLEAN-PRE-07', 'Core pending section headings present before cleanup', ...
    all(pendingSectionsBefore == 1), sprintf('counts=%s', mat2str(pendingSectionsBefore')));

preFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MINOR_EDITORIAL_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', ...
        'Precheck failed.');
end

%% Construct edited text

workTxt = txt;

% Replace the whole local awkward fragment if exact long text is found.
if countLiteral(workTxt, oldHybridSentence) == 1
    workTxt = strrep(workTxt, oldHybridSentence, newHybridSentence);
else
    % Fallback: replace the shorter duplicated transition segment only.
    oldShort = ['R1_solution_3 showed a 43.07% reduction, while For R1_solution_9, ' ...
        'Q_aux decreased from 1773.9 kWh in gas-LPG-only mode to 1218.4 kWh in hybrid mode, ' ...
        'corresponding to a 31.31% reduction. R1_solution_9 showed a lower relative reduction of 31.31%, ' ...
        'consistent with its more aggressive drying condition and higher auxiliary-energy demand.'];
    if countLiteral(workTxt, oldShort) == 1
        workTxt = strrep(workTxt, oldShort, newHybridSentence);
    else
        writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
            'MASTER_MINOR_EDITORIAL_CLEANUP_REVIEW_REQUIRED', ...
            'STOP_WITH_NO_WRITE_AWKWARD_SENTENCE_NOT_EXACTLY_REPLACEABLE', ...
            'Awkward sentence was detected, but exact replacement span was not found.');
    end
end

workTxt = strrep(workTxt, char(sec7StatusPattern), ...
    ['# 7. Results and discussion' newline newline ...
     '`STATUS: STRUCTURALLY_INTEGRATED_CONTENT_REVIEW_PENDING`']);

%% Post-check reconstruction before write

HeadingsAfter = detectCleanHeadings(workTxt);
routeBOKAfter = isRouteBOrderValid(HeadingsAfter);

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-01', 'Route-B order still valid after cleanup reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-02', 'Awkward hybrid sentence removed in reconstruction', ...
    countLiteral(workTxt, awkwardNeedle) == 0, sprintf('count=%d', countLiteral(workTxt, awkwardNeedle)));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-03', 'Corrected hybrid sentence present once in reconstruction', ...
    countLiteral(workTxt, newHybridSentence) == 1, sprintf('count=%d', countLiteral(workTxt, newHybridSentence)));

numsPresentAfter = true;
numEvidenceAfter = strings(numel(requiredNums),1);
for k = 1:numel(requiredNums)
    c = countLiteral(workTxt, char(requiredNums(k)));
    numEvidenceAfter(k) = sprintf('%s=%d', requiredNums(k), c);
    if c == 0
        numsPresentAfter = false;
    end
end

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-04', 'Required numeric values preserved after cleanup reconstruction', ...
    numsPresentAfter, join(numEvidenceAfter, ' | '));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-05', '# 7 status updated conservatively in reconstruction', ...
    countLiteral(workTxt, '`STATUS: STRUCTURALLY_INTEGRATED_CONTENT_REVIEW_PENDING`') == 1, ...
    sprintf('count=%d', countLiteral(workTxt, '`STATUS: STRUCTURALLY_INTEGRATED_CONTENT_REVIEW_PENDING`')));

% Do not remove genuine PENDING markers in still-pending sections.
pendingExpectedStillPresent = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-06', 'PENDING markers in truly pending sections preserved', ...
    pendingExpectedStillPresent, sprintf('preserved=%d', pendingExpectedStillPresent));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-07', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-08', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-09', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-10', 'No GA executed', ...
    true, 'Text-only cleanup');

Tchecks = addCheck(Tchecks, 'MCLEAN-POST-11', 'No drying model executed', ...
    true, 'Text-only cleanup');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MINOR_EDITORIAL_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'MCLEAN-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MINOR_EDITORIAL_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end
fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MCLEAN-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_MINOR_EDITORIAL_CLEANUP_PASS';
decision = 'MASTER_UPDATED_WITH_MINOR_EDITORIAL_CLEANUP';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'Minor editorial cleanup completed.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_MINOR_EDITORIAL_CLEANUP_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function txt = normalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
end

function n = countLiteral(txt, phrase)
    if isstring(txt), txt = char(txt); end
    if isstring(phrase), phrase = char(phrase); end
    n = numel(strfind(txt, phrase));
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

    lineCol = [];
    charCol = [];
    levelCol = [];
    rawCol = strings(0,1);
    titleCol = strings(0,1);

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

function tf = isRouteBOrderValid(Headings)
    idx7  = findHeadingExact(Headings, '# 7. Results and discussion');
    idxD  = findHeadingExact(Headings, '## 7.5 Discussion');
    idx8  = findHeadingExact(Headings, '# 8. Limitations');
    idx9  = findHeadingExact(Headings, '# 9. Conclusions');
    idx10 = findHeadingExact(Headings, '# 10. Nomenclature');
    idx11 = findHeadingExact(Headings, '# 11. References');
    idx12 = findHeadingExact(Headings, '# 12. Supplementary material');

    pos7  = firstChar(Headings, idx7);
    posD  = firstChar(Headings, idxD);
    pos8  = firstChar(Headings, idx8);
    pos9  = firstChar(Headings, idx9);
    pos10 = firstChar(Headings, idx10);
    pos11 = firstChar(Headings, idx11);
    pos12 = firstChar(Headings, idx12);

    tf = all(~isnan([pos7 posD pos8 pos9 pos10 pos11 pos12])) && ...
        pos7 < posD && posD < pos8 && pos8 < pos9 && ...
        pos9 < pos10 && pos10 < pos11 && pos11 < pos12;
end

function ev = routeBEvidence(Headings)
    idx7  = findHeadingExact(Headings, '# 7. Results and discussion');
    idxD  = findHeadingExact(Headings, '## 7.5 Discussion');
    idx8  = findHeadingExact(Headings, '# 8. Limitations');
    idx9  = findHeadingExact(Headings, '# 9. Conclusions');
    idx10 = findHeadingExact(Headings, '# 10. Nomenclature');
    idx11 = findHeadingExact(Headings, '# 11. References');
    idx12 = findHeadingExact(Headings, '# 12. Supplementary material');

    ev = sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', ...
        firstChar(Headings, idx7), firstChar(Headings, idxD), ...
        firstChar(Headings, idx8), firstChar(Headings, idx9), ...
        firstChar(Headings, idx10), firstChar(Headings, idx11), ...
        firstChar(Headings, idx12));
end

function segment = sectionSegmentByHeading(txt, Headings, rawHeading)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx)
        segment = '';
        return;
    end

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

function present = hasUnsupportedGlobalOptimumClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["global optimum", "globally optimal", "global optimality"];
    protective = ["do not", "does not", "no claim", "not claim", "not as", ...
        "not be interpreted", "should not", "avoid", "prohibited", ...
        "restriction", "instead of", "proof of", "not proof", "no prohibited"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedGlobalParetoClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["global pareto front", "complete pareto front", "complete pareto-front characterization"];
    protective = ["do not", "does not", "no claim", "not claim", "not as", ...
        "not be interpreted", "should not", "avoid", "prohibited", ...
        "restriction", "instead of", "use computed nondominated set", "no prohibited"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedStatisticalRobustnessClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["statistically robust", "statistical robustness was demonstrated", ...
        "robust across independent seeds", "robustness across independent seeds was demonstrated"];
    protective = ["does not establish", "does not claim", "no claim", ...
        "additional independent", "would be required", "not as proof", "should not"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid = fopen(outPath, 'w');
    fprintf(fid, 'MASTER HEADINGS DETECTED - MINOR EDITORIAL CLEANUP AFTER\n\n');
    fprintf(fid, 'MASTER: %s\n\n', masterPath);

    for i = 1:height(Headings)
        fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
            i, Headings.line(i), Headings.charpos(i), ...
            Headings.level(i), Headings.raw(i));
    end

    fclose(fid);
end

function writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_MINOR_EDITORIAL_CLEANUP_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-MINOR-EDITORIAL-CLEANUP-v96z-001`\n\n');
    fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid, '## Decision\n\n`%s | %s`\n\n', decision, note);
    fprintf(fid, '## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid, '## Files\n\n');
    fprintf(fid, '- MASTER: `%s`\n', masterPath);
    fprintf(fid, '- Backup target: `%s`\n', backupPath);
    fprintf(fid, '- Headings after: `%s`\n\n', headingsAfterPath);

    failed = Tchecks(~Tchecks.pass, :);
    fprintf(fid, '## Failed checks\n\n');
    if isempty(failed)
        fprintf(fid, 'None.\n\n');
    else
        fprintf(fid, '| id | check | evidence |\n|---|---|---|\n');
        for i = 1:height(failed)
            fprintf(fid, '| `%s` | %s | `%s` |\n', ...
                failed.id(i), failed.check(i), failed.evidence(i));
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '## Checks\n\n');
    fprintf(fid, '| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid, '| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end
    fclose(fid);

    fprintf('\nDiagnosis: %s\n', diagnosis);
    fprintf('Decision:  %s\n', decision);
    fprintf('Note:      %s\n', note);
    fprintf('Report:    %s\n', reportPath);
    fprintf('Checks:    %s\n', checksPath);
    fprintf('\nMASTER_MINOR_EDITORIAL_CLEANUP_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_MINOR_EDITORIAL_CLEANUP_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-MINOR-EDITORIAL-CLEANUP-v96z-001`\n\n');
    fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid, '## Decision\n\n`%s`\n\n', decision);
    fprintf(fid, '## Note\n\n`%s`\n\n', note);
    fprintf(fid, '## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');

    fprintf(fid, '## Files\n\n');
    fprintf(fid, '- MASTER: `%s`\n', masterPath);
    fprintf(fid, '- Backup: `%s`\n', backupPath);
    fprintf(fid, '- Checks: `%s`\n', checksPath);
    fprintf(fid, '- Headings after: `%s`\n\n', headingsAfterPath);

    failed = Tchecks(~Tchecks.pass, :);
    fprintf(fid, '## Failed checks\n\n');
    if isempty(failed)
        fprintf(fid, 'None.\n\n');
    else
        fprintf(fid, '| id | check | evidence |\n|---|---|---|\n');
        for i = 1:height(failed)
            fprintf(fid, '| `%s` | %s | `%s` |\n', ...
                failed.id(i), failed.check(i), failed.evidence(i));
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '## Checks\n\n');
    fprintf(fid, '| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid, '| `%s` | %s | %d | `%s` |\n', ...
            Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end

    fclose(fid);
end
