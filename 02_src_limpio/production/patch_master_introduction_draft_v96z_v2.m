%% patch_master_introduction_draft_v96z_v2.m
% 9.6z-draft-b
% MASTER-INTRODUCTION-DRAFT-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Draft # 3. Introduction in MASTER_manuscript_v01.md.
%
% Scope:
%   1. Replace Introduction scaffold with manuscript prose.
%   2. Update # 3 status to DRAFT_READY_FOR_REVIEW.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not modify Abstract, Keywords, System description, Mathematical model,
%     Optimization methodology, Results, Discussion, Limitations, Conclusions,
%     Nomenclature, References, or Supplementary material.
%   - Does not invent citations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER INTRODUCTION DRAFT v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_INTRODUCTION_DRAFT_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_INTRODUCTION_DRAFT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_INTRODUCTION_DRAFT_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_introduction_draft_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MID-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_INTRODUCTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MID-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);
Tchecks = addCheck(Tchecks, 'MID-PRE-03', 'Route-B order valid before Introduction draft', ...
    routeBOK, routeBEvidence(Headings));

idxIntro = findHeadingExact(Headings, '# 3. Introduction');
idxSystem = findHeadingExact(Headings, '# 4. System description');

Tchecks = addCheck(Tchecks, 'MID-PRE-04', '# 3 Introduction exists once', ...
    numel(idxIntro) == 1, headingSummary(Headings, idxIntro));

Tchecks = addCheck(Tchecks, 'MID-PRE-05', '# 4 System description exists once', ...
    numel(idxSystem) == 1, headingSummary(Headings, idxSystem));

introSeg = sectionSegmentByHeading(txt, Headings, '# 3. Introduction');

Tchecks = addCheck(Tchecks, 'MID-PRE-06', 'Introduction currently marked PENDING', ...
    contains(string(introSeg), '`STATUS: PENDING`'), sprintf('present=%d', contains(string(introSeg), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MID-PRE-07', 'Introduction scaffold contains Expected structure', ...
    contains(string(introSeg), 'Expected structure:'), sprintf('present=%d', contains(string(introSeg), 'Expected structure:')));

expectedSubheads = ["## 3.1 Context", "## 3.2 Problem", "## 3.3 Gap", "## 3.4 Contribution", "## 3.5 Scope and limitation"];
subheadEvidence = strings(numel(expectedSubheads),1);

for k = 1:numel(expectedSubheads)
    c = countLiteral(introSeg, char(expectedSubheads(k)));
    subheadEvidence(k) = sprintf('%s=%d', expectedSubheads(k), c);
end

% v2: Do not require scaffold subheadings. In the current MASTER, #3 keeps
% Expected structure, but the old ##3.1--##3.5 labels are already absent.
Tchecks = addCheck(Tchecks, 'MID-PRE-08', 'Introduction scaffold boundary acceptable', ...
    contains(string(introSeg), 'Expected structure:'), join(subheadEvidence, ' | '));

% Required anchors in manuscript. These ensure the intro is grounded in the current project state.
requiredAnchors = [
    "hybrid solar--LPG tunnel dryer"
    "controlled recirculation"
    "collector-efficiency sensitivity"
    "computed nondominated set"
    "R1_solution_7"
    "H2"
    "2-SAH"
    "MR <= 0.1"
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

Tchecks = addCheck(Tchecks, 'MID-PRE-09', 'Required manuscript anchors exist before drafting', ...
    anchorsOK, join(anchorEvidence, ' | '));

% Protect already-drafted front matter.
abstractReady = contains(string(sectionSegmentByHeading(txt, Headings, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`');
keywordsReady = contains(string(sectionSegmentByHeading(txt, Headings, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`');

Tchecks = addCheck(Tchecks, 'MID-PRE-10', 'Abstract and Keywords already draft-ready before Introduction draft', ...
    abstractReady && keywordsReady, sprintf('abstract=%d keywords=%d', abstractReady, keywordsReady));

preFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_INTRODUCTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', ...
        'Precheck failed.');
end

%% Draft Introduction block

introBlock = [
"# 3. Introduction" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"Hybrid solar drying is a relevant route for reducing fossil auxiliary-energy demand in thermal processing of agricultural products, particularly when drying must be maintained under controlled temperature and airflow conditions. In tunnel dryers, the useful contribution of the solar field depends not only on the available solar resource, but also on how the process air is heated, mixed, recirculated, and supplemented by an auxiliary fuel system. For hybrid solar--LPG operation, the resulting control problem is therefore not a single-variable temperature-setting problem; it involves simultaneous decisions on airflow, minimum process temperature, recirculation ratio, and recirculation start time." newline newline ...
"The operational challenge is that drying performance, auxiliary energy demand, economic indicators, and CO2-related indicators do not improve simultaneously. Deeper drying generally requires larger thermal input, while lower-energy operation may be acceptable only if the final moisture-ratio criterion remains satisfied. A useful optimization framework must therefore distinguish between excessive drying and sufficient drying, and it must identify feasible candidates that satisfy the selected moisture criterion without unnecessarily increasing auxiliary energy use. In this manuscript, feasibility is interpreted through the final moisture-ratio condition MR <= 0.1." newline newline ...
"Solar air heater representation is another source of uncertainty in the interpretation of hybrid dryer performance. A constant collector-efficiency assumption can simplify the energy balance, but it may distort the estimated auxiliary-energy demand. Conversely, a more physically consistent efficiency representation can change the absolute magnitude of the solar contribution. For the present system, the solar field is represented by batteries with two solar air heaters in series, which motivates a collector-efficiency sensitivity analysis based on the 2-SAH curve. This sensitivity is used to assess whether the selected operating-point ranking is preserved when the collector-efficiency assumption is changed." newline newline ...
"The present work addresses these issues by assembling a controlled multiobjective optimization and post-processing workflow for a hybrid solar--LPG tunnel dryer with explicit recirculation timing and collector-efficiency sensitivity. The optimization problem evaluates the trade-off among final moisture ratio, auxiliary-energy-related economic performance, and CO2-related environmental indicators. The formal R1 run is interpreted as a controlled seed-aware numerical realization, and its output is reported as a computed nondominated set rather than as proof of global optimality or statistical robustness. The selected R1 candidates are compared against the historical H2 reference point and against a pointwise gas-LPG-only baseline to separate optimization behavior from fuel-substitution effects." newline newline ...
"The contribution of this manuscript is fourfold. First, it formalizes the operational selection of feasible hybrid dryer candidates using air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time as decision variables. Second, it identifies R1_solution_7 as the main energy-conservative feasible candidate and R1_solution_3 as a balanced alternative, while retaining R1_solution_9 as an aggressive drying boundary case and H2 as a historical reference. Third, it evaluates whether the 2-SAH collector-efficiency assumption changes the qualitative ranking of the selected points. Fourth, it compares the selected hybrid operating points against gas-LPG-only operation to quantify auxiliary-energy reduction under equivalent decision-variable settings." newline newline ...
"The scope of the study is limited to the implemented drying model, the specified operational bounds, and one formal seed-aware R1 run. The analysis does not claim complete search-space convergence, statistical robustness across independent random seeds, or complete equipment-level optimality. Fan-power consumption, pressure-drop coupling, fully coupled dynamic collector modeling, and final source-locked cost and CO2 factors remain necessary extensions before publication-level techno-economic and environmental claims are made." newline ...
];

% Guard checks on draft block.
Tchecks = addCheck(Tchecks, 'MID-DRAFT-01', 'Draft Introduction contains hybrid solar--LPG framing', ...
    contains(string(introBlock), 'hybrid solar--LPG'), sprintf('present=%d', contains(string(introBlock), 'hybrid solar--LPG')));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-02', 'Draft Introduction contains feasibility criterion', ...
    contains(string(introBlock), 'MR <= 0.1'), sprintf('present=%d', contains(string(introBlock), 'MR <= 0.1')));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-03', 'Draft Introduction contains 2-SAH sensitivity framing', ...
    contains(string(introBlock), '2-SAH') && contains(lower(string(introBlock)), 'sensitivity'), ...
    sprintf('2SAH=%d sensitivity=%d', contains(string(introBlock), '2-SAH'), contains(lower(string(introBlock)), 'sensitivity')));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-04', 'Draft Introduction contains candidate roles', ...
    all([contains(string(introBlock),'R1_solution_7'), contains(string(introBlock),'R1_solution_3'), contains(string(introBlock),'R1_solution_9'), contains(string(introBlock),'H2')]), ...
    sprintf('R1_7=%d R1_3=%d R1_9=%d H2=%d', contains(string(introBlock),'R1_solution_7'), contains(string(introBlock),'R1_solution_3'), contains(string(introBlock),'R1_solution_9'), contains(string(introBlock),'H2')));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-05', 'Draft Introduction preserves computed nondominated set wording', ...
    contains(string(introBlock), 'computed nondominated set'), sprintf('present=%d', contains(string(introBlock), 'computed nondominated set')));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-06', 'Draft Introduction has no unsupported global optimality claim', ...
    ~hasUnsupportedGlobalOptimumClaim(introBlock), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(introBlock)));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-07', 'Draft Introduction has no unsupported statistical robustness claim', ...
    ~hasUnsupportedStatisticalRobustnessClaim(introBlock), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(introBlock)));

Tchecks = addCheck(Tchecks, 'MID-DRAFT-08', 'Draft Introduction avoids citation placeholders', ...
    ~contains(string(introBlock), 'CITATION_NEEDED') && ~contains(string(introBlock), 'TODO') && ~contains(string(introBlock), 'TBD'), ...
    'No citation placeholders in draft block');

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_INTRODUCTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft block failed guard checks.');
end

%% Reconstruct text

workTxt = replaceSectionByHeading(txt, Headings, '# 3. Introduction', introBlock);
HeadingsAfter = detectCleanHeadings(workTxt);

%% Post reconstruction checks

routeBOKAfter = isRouteBOrderValid(HeadingsAfter);
Tchecks = addCheck(Tchecks, 'MID-POST-01', 'Route-B order valid after Introduction reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

introAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction');

Tchecks = addCheck(Tchecks, 'MID-POST-02', 'Introduction status updated', ...
    contains(string(introAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(introAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'MID-POST-03', 'Introduction PENDING marker removed', ...
    ~contains(string(introAfter), '`STATUS: PENDING`'), ...
    sprintf('present=%d', contains(string(introAfter), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MID-POST-04', 'Introduction Expected structure scaffold removed', ...
    ~contains(string(introAfter), 'Expected structure:'), ...
    sprintf('present=%d', contains(string(introAfter), 'Expected structure:')));

oldSubheadsRemoved = true;
oldSubheadEvidence = strings(numel(expectedSubheads),1);
for k = 1:numel(expectedSubheads)
    c = countLiteral(introAfter, char(expectedSubheads(k)));
    oldSubheadEvidence(k) = sprintf('%s=%d', expectedSubheads(k), c);
    if c ~= 0
        oldSubheadsRemoved = false;
    end
end

Tchecks = addCheck(Tchecks, 'MID-POST-05', 'Old Introduction scaffold subheadings removed', ...
    oldSubheadsRemoved, join(oldSubheadEvidence, ' | '));

Tchecks = addCheck(Tchecks, 'MID-POST-06', 'Introduction contains contribution paragraph', ...
    contains(string(introAfter), 'The contribution of this manuscript is fourfold'), ...
    sprintf('present=%d', contains(string(introAfter), 'The contribution of this manuscript is fourfold')));

Tchecks = addCheck(Tchecks, 'MID-POST-07', 'Introduction contains scope limitation paragraph', ...
    contains(string(introAfter), 'The scope of the study is limited'), ...
    sprintf('present=%d', contains(string(introAfter), 'The scope of the study is limited')));

% Ensure other sections remain in expected states.
frontMatterStillReady = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

otherPendingStillPending = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'MID-POST-08', 'Abstract and Keywords remain draft-ready', ...
    frontMatterStillReady, sprintf('ready=%d', frontMatterStillReady));

Tchecks = addCheck(Tchecks, 'MID-POST-09', 'Other genuine pending sections preserved', ...
    otherPendingStillPending, sprintf('pendingPreserved=%d', otherPendingStillPending));

Tchecks = addCheck(Tchecks, 'MID-POST-10', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MID-POST-11', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MID-POST-12', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MID-POST-13', 'No GA executed', ...
    true, 'Text-only Introduction draft');

Tchecks = addCheck(Tchecks, 'MID-POST-14', 'No drying model executed', ...
    true, 'Text-only Introduction draft');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_INTRODUCTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'MID-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_INTRODUCTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end

fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MID-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_INTRODUCTION_DRAFT_PASS';
decision = 'MASTER_UPDATED_WITH_INTRODUCTION_DRAFT';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'Introduction drafted with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_INTRODUCTION_DRAFT_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    if isempty(pass)
        passScalar = false;
    else
        passScalar = all(logical(pass(:)));
    end

    if ischar(evidence)
        evidenceScalar = string(evidence);
    elseif isstring(evidence)
        evidenceScalar = strjoin(evidence(:).', ' | ');
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
            Headings.line(ii), Headings.charpos(ii), Headings.level(ii), Headings.raw(ii));
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
    fprintf(fid, 'MASTER HEADINGS DETECTED - INTRODUCTION DRAFT AFTER\n\n');
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
    fprintf(fid, '# MASTER_INTRODUCTION_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-INTRODUCTION-DRAFT-v96z-001`\n\n');
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
    fprintf('\nMASTER_INTRODUCTION_DRAFT_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_INTRODUCTION_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-INTRODUCTION-DRAFT-v96z-001`\n\n');
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
