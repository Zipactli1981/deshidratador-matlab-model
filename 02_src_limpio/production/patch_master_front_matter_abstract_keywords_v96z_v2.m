%% patch_master_front_matter_abstract_keywords_v96z_v2.m
% 9.6z-draft-a
% MASTER-FRONT-MATTER-DRAFT-ABSTRACT-KEYWORDS-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Draft the front matter of MASTER_manuscript_v01.md:
%   - # 1. Abstract
%   - # 2. Keywords
%
% Scope:
%   1. Replace Abstract scaffold with a manuscript-ready draft.
%   2. Replace Candidate keywords scaffold with finalized keywords.
%   3. Update #1 and #2 statuses to DRAFT_READY_FOR_REVIEW.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not modify Introduction, System description, Mathematical model,
%     Optimization methodology, References, Results, Discussion, Limitations,
%     or Conclusions.
%   - Does not invent citations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER FRONT MATTER DRAFT ABSTRACT KEYWORDS v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_FRONT_MATTER_DRAFT_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_front_matter_draft_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);
Tchecks = addCheck(Tchecks, 'FMDAK-PRE-03', 'Route-B order valid before front-matter draft', ...
    routeBOK, routeBEvidence(Headings));

idxAbstract = findHeadingExact(Headings, '# 1. Abstract');
idxKeywords = findHeadingExact(Headings, '# 2. Keywords');
idxIntro = findHeadingExact(Headings, '# 3. Introduction');

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-04', '# 1 Abstract exists once', ...
    numel(idxAbstract) == 1, headingSummary(Headings, idxAbstract));

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-05', '# 2 Keywords exists once', ...
    numel(idxKeywords) == 1, headingSummary(Headings, idxKeywords));

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-06', '# 3 Introduction exists once', ...
    numel(idxIntro) == 1, headingSummary(Headings, idxIntro));

abstractSeg = sectionSegmentByHeading(txt, Headings, '# 1. Abstract');
keywordsSeg = sectionSegmentByHeading(txt, Headings, '# 2. Keywords');

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-07', 'Abstract currently marked PENDING', ...
    contains(string(abstractSeg), '`STATUS: PENDING`'), sprintf('present=%d', contains(string(abstractSeg), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-08', 'Abstract scaffold contains Expected content', ...
    contains(string(abstractSeg), 'Expected content:'), sprintf('present=%d', contains(string(abstractSeg), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-09', 'Keywords currently marked PENDING', ...
    contains(string(keywordsSeg), '`STATUS: PENDING`'), sprintf('present=%d', contains(string(keywordsSeg), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-10', 'Keywords scaffold contains Candidate keywords', ...
    contains(string(keywordsSeg), 'Candidate keywords:'), sprintf('present=%d', contains(string(keywordsSeg), 'Candidate keywords:')));

% Required technical anchors from the current manuscript.
requiredAnchors = [
    "R1_solution_7"
    "R1_solution_3"
    "R1_solution_9"
    "H2"
    "2-SAH"
    "MR ≤ 0.1"
    "Q_aux = 656.23 kWh"
    "hybrid operation reduced the auxiliary energy demand"
    "computed nondominated set"
];

anchorsOK = true;
anchorEvidence = strings(numel(requiredAnchors),1);

for k = 1:numel(requiredAnchors)
    c = countLiteral(txt, char(requiredAnchors(k)));
    anchorEvidence(k) = sprintf('%s=%d', requiredAnchors(k), c);
    if c == 0
        anchorsOK = false;
    end
end

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-11', 'Required technical anchors exist before drafting', ...
    anchorsOK, join(anchorEvidence, ' | '));

% Ensure genuine pending major sections other than front matter remain present.
otherPendingSectionsOK = all([
    contains(string(sectionSegmentByHeading(txt, Headings, '# 3. Introduction')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 4. System description')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 5. Mathematical model')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'FMDAK-PRE-12', 'Other genuine pending sections still present before drafting', ...
    otherPendingSectionsOK, sprintf('present=%d', otherPendingSectionsOK));

preFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', ...
        'Precheck failed.');
end

%% Draft replacement content

abstractBlock = [
"# 1. Abstract" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"This study evaluates the operational optimization of a hybrid solar--LPG tunnel dryer with controlled air recirculation and collector-efficiency sensitivity. A multiobjective genetic-algorithm workflow was applied to a drying model of the hybrid system, using air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time as decision variables. The formal R1 run was treated as a controlled seed-aware numerical realization and its output is therefore reported as a computed nondominated set, not as evidence of global optimality or statistical robustness across independent seeds. Feasibility was assessed using a final moisture-ratio criterion of MR <= 0.1." newline newline ...
"Among the selected operating points, R1_solution_7 was identified as the main energy-conservative feasible candidate, reaching MR = 0.07057 with Q_aux = 656.23 kWh under the 2-SAH collector-efficiency assumption. R1_solution_3 provided a balanced alternative with deeper drying and higher auxiliary-energy demand, whereas R1_solution_9 represented an aggressive drying case with a substantial energy penalty. The historical H2 point was retained only as a reference condition for comparison and was not treated as a newly optimized R1 solution." newline newline ...
"The collector-efficiency sensitivity analysis showed that replacing the constant-efficiency assumption with the 2-SAH curve changed the absolute auxiliary-energy values but preserved the qualitative ranking of the selected operating points. A pointwise hybrid versus gas-LPG-only baseline comparison further indicated that hybrid operation reduced auxiliary-energy demand while maintaining feasible final moisture-ratio behavior. These results support the hybrid solar--LPG configuration as a promising energy-saving operating strategy under the modeled conditions. Final economic and CO2 claims remain conditional on definitive fuel-price, tariff, emission-factor, source-year, regional, unit-basis, and conversion assumptions." newline ...
];

keywordsBlock = [
"# 2. Keywords" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"- Hybrid solar dryer" newline ...
"- LPG auxiliary heating" newline ...
"- Tunnel drying" newline ...
"- Multiobjective optimization" newline ...
"- Moisture ratio" newline ...
"- Solar air heater" newline ...
"- Collector-efficiency sensitivity" newline ...
"- Recirculation control" newline ...
];

% Normalize draft blocks to scalar character vectors.
abstractBlock = char(join(string(abstractBlock), ''));
keywordsBlock = char(join(string(keywordsBlock), ''));

% Validate draft content before insertion.
Tchecks = addCheck(Tchecks, 'FMDAK-DRAFT-01', 'Draft abstract uses computed nondominated set wording', ...
    contains(string(abstractBlock), 'computed nondominated set'), sprintf('present=%d', contains(string(abstractBlock), 'computed nondominated set')));

Tchecks = addCheck(Tchecks, 'FMDAK-DRAFT-02', 'Draft abstract does not make unsupported global optimality claim', ...
    ~hasUnsupportedGlobalOptimumClaim(abstractBlock), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(abstractBlock)));

Tchecks = addCheck(Tchecks, 'FMDAK-DRAFT-03', 'Draft abstract does not make unsupported statistical robustness claim', ...
    ~hasUnsupportedStatisticalRobustnessClaim(abstractBlock), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(abstractBlock)));

Tchecks = addCheck(Tchecks, 'FMDAK-DRAFT-04', 'Draft abstract preserves conditional cost/CO2 framing', ...
    contains(string(abstractBlock), 'Final economic and CO2 claims remain conditional'), ...
    sprintf('present=%d', contains(string(abstractBlock), 'Final economic and CO2 claims remain conditional')));

Tchecks = addCheck(Tchecks, 'FMDAK-DRAFT-05', 'Draft keywords contain 8 items', ...
    countListItems(keywordsBlock) == 8, sprintf('items=%d', countListItems(keywordsBlock)));

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft block failed guard checks.');
end

%% Reconstruct text

workTxt = replaceSectionByHeading(txt, Headings, '# 1. Abstract', abstractBlock);
HeadingsWork = detectCleanHeadings(workTxt);
workTxt = replaceSectionByHeading(workTxt, HeadingsWork, '# 2. Keywords', keywordsBlock);

HeadingsAfter = detectCleanHeadings(workTxt);

%% Post reconstruction checks

routeBOKAfter = isRouteBOrderValid(HeadingsAfter);
Tchecks = addCheck(Tchecks, 'FMDAK-POST-01', 'Route-B order valid after reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

segAbstractAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract');
segKeywordsAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords');

Tchecks = addCheck(Tchecks, 'FMDAK-POST-02', 'Abstract status updated', ...
    contains(string(segAbstractAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(segAbstractAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-03', 'Keywords status updated', ...
    contains(string(segKeywordsAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(segKeywordsAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-04', 'Abstract PENDING marker removed only from Abstract', ...
    ~contains(string(segAbstractAfter), '`STATUS: PENDING`'), ...
    sprintf('abstractPending=%d', contains(string(segAbstractAfter), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-05', 'Keywords PENDING marker removed only from Keywords', ...
    ~contains(string(segKeywordsAfter), '`STATUS: PENDING`'), ...
    sprintf('keywordsPending=%d', contains(string(segKeywordsAfter), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-06', 'Abstract scaffold removed', ...
    ~contains(string(segAbstractAfter), 'Expected content:'), ...
    sprintf('present=%d', contains(string(segAbstractAfter), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-07', 'Keywords scaffold removed', ...
    ~contains(string(segKeywordsAfter), 'Candidate keywords:'), ...
    sprintf('present=%d', contains(string(segKeywordsAfter), 'Candidate keywords:')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-08', 'Abstract contains key values and candidates', ...
    all([contains(string(segAbstractAfter),'R1_solution_7'), ...
         contains(string(segAbstractAfter),'R1_solution_3'), ...
         contains(string(segAbstractAfter),'R1_solution_9'), ...
         contains(string(segAbstractAfter),'H2'), ...
         contains(string(segAbstractAfter),'MR = 0.07057'), ...
         contains(string(segAbstractAfter),'Q_aux = 656.23 kWh'), ...
         contains(string(segAbstractAfter),'2-SAH')]), ...
    sprintf('R1_7=%d R1_3=%d R1_9=%d H2=%d MR=%d Qaux=%d 2SAH=%d', ...
        contains(string(segAbstractAfter),'R1_solution_7'), ...
        contains(string(segAbstractAfter),'R1_solution_3'), ...
        contains(string(segAbstractAfter),'R1_solution_9'), ...
        contains(string(segAbstractAfter),'H2'), ...
        contains(string(segAbstractAfter),'MR = 0.07057'), ...
        contains(string(segAbstractAfter),'Q_aux = 656.23 kWh'), ...
        contains(string(segAbstractAfter),'2-SAH')));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-09', 'Keywords contain 8 finalized items', ...
    countListItems(segKeywordsAfter) == 8, sprintf('items=%d', countListItems(segKeywordsAfter)));

% Other pending major sections must remain marked pending.
otherPendingAfterOK = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'FMDAK-POST-10', 'Other genuine pending sections preserved', ...
    otherPendingAfterOK, sprintf('preserved=%d', otherPendingAfterOK));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-11', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-12', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-13', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'FMDAK-POST-14', 'No GA executed', ...
    true, 'Text-only front matter draft');

Tchecks = addCheck(Tchecks, 'FMDAK-POST-15', 'No drying model executed', ...
    true, 'Text-only front matter draft');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'FMDAK-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end

fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'FMDAK-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_PASS';
decision = 'MASTER_UPDATED_WITH_ABSTRACT_KEYWORDS_DRAFT';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'Abstract and Keywords drafted with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    % Robust scalarization: some MATLAB contains/count expressions may return vectors.
    if isempty(pass)
        passScalar = false;
    else
        passScalar = all(logical(pass(:)));
    end

    if isstring(evidence) || ischar(evidence)
        evidenceScalar = strjoin(string(evidence(:)).', ' | ');
    else
        evidenceScalar = string(evidence);
    end

    T = [T; table(string(id), string(check), logical(passScalar), string(evidenceScalar), ...
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

function s = headingSummary(Headings, idx)
    if isempty(idx)
        s = "NOT_DETECTED";
        return;
    end
    parts = strings(numel(idx),1);
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', ...
            Headings.line(ii), Headings.charpos(ii), ...
            Headings.level(ii), Headings.raw(ii));
    end
    s = join(parts, ' || ');
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

function txtOut = replaceSectionByHeading(txt, Headings, rawHeading, newBlock)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx)
        error('Heading not found for replacement: %s', rawHeading);
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

    before = extractBefore(string(txt), startPos);
    after = extractAfter(string(txt), endPos-1);

    txtOut = char(before + string(newBlock) + newline + after);
end

function n = countListItems(seg)
    lines = splitlines(string(seg));
    n = 0;
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        if startsWith(li, "- ") || startsWith(li, "* ") || ~isempty(regexp(char(li), '^\d+\.\s+', 'once'))
            n = n + 1;
        end
    end
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
    fprintf(fid, 'MASTER HEADINGS DETECTED - FRONT MATTER DRAFT AFTER\n\n');
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
    fprintf(fid, '# MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-FRONT-MATTER-DRAFT-ABSTRACT-KEYWORDS-v96z-001`\n\n');
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
            fprintf(fid, '| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i));
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '## Checks\n\n');
    fprintf(fid, '| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid, '| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end
    fclose(fid);

    fprintf('\nDiagnosis: %s\n', diagnosis);
    fprintf('Decision:  %s\n', decision);
    fprintf('Note:      %s\n', note);
    fprintf('Report:    %s\n', reportPath);
    fprintf('Checks:    %s\n', checksPath);
    fprintf('\nMASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_FRONT_MATTER_DRAFT_ABSTRACT_KEYWORDS_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-FRONT-MATTER-DRAFT-ABSTRACT-KEYWORDS-v96z-001`\n\n');
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
            fprintf(fid, '| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i));
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '## Checks\n\n');
    fprintf(fid, '| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid, '| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end

    fclose(fid);
end
