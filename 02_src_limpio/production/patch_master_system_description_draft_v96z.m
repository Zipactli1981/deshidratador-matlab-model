%% patch_master_system_description_draft_v96z.m
% 9.6z-draft-c
% MASTER-SYSTEM-DESCRIPTION-DRAFT-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Draft # 4. System description in MASTER_manuscript_v01.md.
%
% Scope:
%   1. Replace System description scaffold with manuscript prose.
%   2. Preserve FIG_01_system_schematic as a figure callout, not as a generated figure.
%   3. Update # 4 status to DRAFT_READY_FOR_REVIEW.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not modify Abstract, Keywords, Introduction, Mathematical model,
%     Optimization methodology, Results, Discussion, Limitations, Conclusions,
%     Nomenclature, References, or Supplementary material.
%   - Does not invent citations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER SYSTEM DESCRIPTION DRAFT v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_SYSTEM_DESCRIPTION_DRAFT_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_SYSTEM_DESCRIPTION_DRAFT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_SYSTEM_DESCRIPTION_DRAFT_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_system_description_draft_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MSD-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_SYSTEM_DESCRIPTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MSD-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);
Tchecks = addCheck(Tchecks, 'MSD-PRE-03', 'Route-B order valid before System description draft', ...
    routeBOK, routeBEvidence(Headings));

idxSystem = findHeadingExact(Headings, '# 4. System description');
idxModel  = findHeadingExact(Headings, '# 5. Mathematical model');

Tchecks = addCheck(Tchecks, 'MSD-PRE-04', '# 4 System description exists once', ...
    numel(idxSystem) == 1, headingSummary(Headings, idxSystem));

Tchecks = addCheck(Tchecks, 'MSD-PRE-05', '# 5 Mathematical model exists once', ...
    numel(idxModel) == 1, headingSummary(Headings, idxModel));

systemSeg = sectionSegmentByHeading(txt, Headings, '# 4. System description');

Tchecks = addCheck(Tchecks, 'MSD-PRE-06', 'System description currently marked PENDING', ...
    contains(string(systemSeg), '`STATUS: PENDING`'), ...
    sprintf('present=%d', contains(string(systemSeg), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MSD-PRE-07', 'System description scaffold contains Expected content', ...
    contains(string(systemSeg), 'Expected content:'), ...
    sprintf('present=%d', contains(string(systemSeg), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'MSD-PRE-08', 'System description contains Expected figure scaffold', ...
    contains(string(systemSeg), 'Expected figure:') || contains(string(systemSeg), 'FIG_01_system_schematic'), ...
    sprintf('Expected figure=%d | FIG_01=%d', contains(string(systemSeg), 'Expected figure:'), contains(string(systemSeg), 'FIG_01_system_schematic')));

% Protect already-drafted earlier sections.
abstractReady = contains(string(sectionSegmentByHeading(txt, Headings, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`');
keywordsReady = contains(string(sectionSegmentByHeading(txt, Headings, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`');
introReady    = contains(string(sectionSegmentByHeading(txt, Headings, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`');

Tchecks = addCheck(Tchecks, 'MSD-PRE-09', 'Front matter and Introduction already draft-ready', ...
    abstractReady && keywordsReady && introReady, ...
    sprintf('abstract=%d keywords=%d introduction=%d', abstractReady, keywordsReady, introReady));

% Required manuscript/system anchors.
requiredAnchors = [
    "hybrid solar--LPG tunnel dryer"
    "solar air heaters"
    "two solar air heaters in series"
    "controlled recirculation"
    "LPG"
    "2-SAH"
    "air mass flow rate"
    "minimum process temperature"
    "recirculation ratio"
    "recirculation start time"
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

Tchecks = addCheck(Tchecks, 'MSD-PRE-10', 'Required system anchors exist before drafting', ...
    anchorsOK, join(anchorEvidence, ' | '));

preFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_SYSTEM_DESCRIPTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', ...
        'Precheck failed.');
end

%% Draft System description block

systemBlock = [
"# 4. System description" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"The analyzed equipment is a hybrid solar--LPG tunnel dryer configured for forced-convection drying under controlled airflow, auxiliary heating, and air-recirculation conditions. The system combines a solar air-heating field with an LPG auxiliary heater so that the process-air temperature can be maintained when the instantaneous solar contribution is insufficient. The dryer is represented at the operational level by the main airflow path, the solar air-heater contribution, the auxiliary LPG heating stage, the drying chamber, and the recirculation branch." newline newline ...
"The drying-air stream is driven by a forced-flow system and is heated before entering the tunnel chamber. Under hybrid operation, part of the required sensible heat is supplied by the solar air-heater field and the remaining demand is supplied by the LPG auxiliary heater whenever the process-air temperature must be lifted to the selected minimum operating level. The auxiliary-energy variable Q_aux is therefore interpreted as the thermal demand assigned to the LPG system after accounting for the modeled solar contribution." newline newline ...
"The solar subsystem is represented through collector-efficiency assumptions rather than through a fully coupled dynamic collector model. In the baseline formulation, the solar contribution can be estimated with a simplified efficiency representation. In the sensitivity analysis, the solar field is represented using the 2-SAH collector-efficiency curve, consistent with batteries composed of two solar air heaters in series. This sensitivity is used to evaluate whether the selected operating-point ranking remains consistent when the solar-air-heater efficiency representation is changed." newline newline ...
"The recirculation subsystem allows a fraction of the outlet air to be returned to the process stream after a specified recirculation start time. In the optimization workflow, the relevant operational decision variables are the air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. These variables jointly define the thermal severity, residence-time effect, and energy-reuse behavior of each simulated operating condition. The recirculation start time is treated explicitly because early and delayed recirculation can affect both moisture removal and auxiliary-energy demand." newline newline ...
"The drying chamber contains the agricultural product and is modeled through lumped dynamic states that represent the interaction between drying air, product moisture removal, and thermal response of the system. The final drying performance is evaluated using the final moisture ratio, with feasible operation defined in this manuscript by MR <= 0.1. The comparison between hybrid operation and gas-LPG-only operation is performed pointwise at selected operating conditions, so the difference in Q_aux reflects the modeled solar contribution under the same decision-variable settings." newline newline ...
"Figure 1 should present a schematic of the hybrid solar--LPG dryer, including the solar air-heater field, auxiliary LPG heater, drying chamber, exhaust path, recirculation branch, controlled recirculation ratio, recirculation start-time logic, and main measured or simulated variables." newline newline ...
"`FIG_01_system_schematic`: pending figure callout; schematic to be inserted during figure-preparation stage." newline ...
];

% Normalize draft block to scalar char.
systemBlock = char(join(string(systemBlock), ''));

%% Guard checks on draft block

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-01', 'Draft contains hybrid solar--LPG system framing', ...
    contains(string(systemBlock), 'hybrid solar--LPG tunnel dryer'), ...
    sprintf('present=%d', contains(string(systemBlock), 'hybrid solar--LPG tunnel dryer')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-02', 'Draft contains solar air-heater and 2-SAH framing', ...
    contains(string(systemBlock), 'solar air-heater') && contains(string(systemBlock), '2-SAH'), ...
    sprintf('solarAirHeater=%d 2SAH=%d', contains(string(systemBlock), 'solar air-heater'), contains(string(systemBlock), '2-SAH')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-03', 'Draft contains LPG auxiliary-heating interpretation', ...
    contains(string(systemBlock), 'LPG auxiliary heater') && contains(string(systemBlock), 'Q_aux'), ...
    sprintf('LPGaux=%d Qaux=%d', contains(string(systemBlock), 'LPG auxiliary heater'), contains(string(systemBlock), 'Q_aux')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-04', 'Draft contains recirculation decision variables', ...
    all([contains(string(systemBlock), 'air mass flow rate'), ...
         contains(string(systemBlock), 'minimum process temperature'), ...
         contains(string(systemBlock), 'recirculation ratio'), ...
         contains(string(systemBlock), 'recirculation start time')]), ...
    sprintf('mdot=%d Tmin=%d rrec=%d trec=%d', ...
        contains(string(systemBlock), 'air mass flow rate'), ...
        contains(string(systemBlock), 'minimum process temperature'), ...
        contains(string(systemBlock), 'recirculation ratio'), ...
        contains(string(systemBlock), 'recirculation start time')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-05', 'Draft contains MR feasibility criterion', ...
    contains(string(systemBlock), 'MR <= 0.1'), ...
    sprintf('present=%d', contains(string(systemBlock), 'MR <= 0.1')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-06', 'Draft preserves figure callout without inventing figure', ...
    contains(string(systemBlock), 'FIG_01_system_schematic') && contains(lower(string(systemBlock)), 'pending figure callout'), ...
    sprintf('FIG_01=%d pending=%d', contains(string(systemBlock), 'FIG_01_system_schematic'), contains(lower(string(systemBlock)), 'pending figure callout')));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-07', 'Draft avoids citation placeholders', ...
    ~contains(string(systemBlock), 'CITATION_NEEDED') && ~contains(string(systemBlock), 'TODO') && ~contains(string(systemBlock), 'TBD'), ...
    'No citation placeholders in draft block');

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-08', 'Draft does not introduce unsupported global optimality claim', ...
    ~hasUnsupportedGlobalOptimumClaim(systemBlock), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(systemBlock)));

Tchecks = addCheck(Tchecks, 'MSD-DRAFT-09', 'Draft does not introduce unsupported statistical robustness claim', ...
    ~hasUnsupportedStatisticalRobustnessClaim(systemBlock), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(systemBlock)));

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_SYSTEM_DESCRIPTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft block failed guard checks.');
end

%% Reconstruct text

workTxt = replaceSectionByHeading(txt, Headings, '# 4. System description', systemBlock);
HeadingsAfter = detectCleanHeadings(workTxt);

%% Post reconstruction checks

routeBOKAfter = isRouteBOrderValid(HeadingsAfter);
Tchecks = addCheck(Tchecks, 'MSD-POST-01', 'Route-B order valid after System description reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

systemAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description');

Tchecks = addCheck(Tchecks, 'MSD-POST-02', 'System description status updated', ...
    contains(string(systemAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(systemAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'MSD-POST-03', 'System description PENDING marker removed', ...
    ~contains(string(systemAfter), '`STATUS: PENDING`'), ...
    sprintf('present=%d', contains(string(systemAfter), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MSD-POST-04', 'System description Expected content scaffold removed', ...
    ~contains(string(systemAfter), 'Expected content:'), ...
    sprintf('present=%d', contains(string(systemAfter), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'MSD-POST-05', 'Expected figure scaffold converted to figure callout', ...
    ~contains(string(systemAfter), 'Expected figure:') && contains(string(systemAfter), 'FIG_01_system_schematic'), ...
    sprintf('ExpectedFigure=%d FIG_01=%d', contains(string(systemAfter), 'Expected figure:'), contains(string(systemAfter), 'FIG_01_system_schematic')));

Tchecks = addCheck(Tchecks, 'MSD-POST-06', 'System description contains main subsystem description', ...
    all([contains(string(systemAfter), 'solar air-heater'), ...
         contains(string(systemAfter), 'LPG auxiliary heater'), ...
         contains(string(systemAfter), 'drying chamber'), ...
         contains(string(systemAfter), 'recirculation branch')]), ...
    sprintf('SAH=%d LPG=%d chamber=%d recircBranch=%d', ...
        contains(string(systemAfter), 'solar air-heater'), ...
        contains(string(systemAfter), 'LPG auxiliary heater'), ...
        contains(string(systemAfter), 'drying chamber'), ...
        contains(string(systemAfter), 'recirculation branch')));

Tchecks = addCheck(Tchecks, 'MSD-POST-07', 'System description contains decision variables and MR criterion', ...
    all([contains(string(systemAfter), 'air mass flow rate'), ...
         contains(string(systemAfter), 'minimum process temperature'), ...
         contains(string(systemAfter), 'recirculation ratio'), ...
         contains(string(systemAfter), 'recirculation start time'), ...
         contains(string(systemAfter), 'MR <= 0.1')]), ...
    sprintf('mdot=%d Tmin=%d rrec=%d trec=%d MR=%d', ...
        contains(string(systemAfter), 'air mass flow rate'), ...
        contains(string(systemAfter), 'minimum process temperature'), ...
        contains(string(systemAfter), 'recirculation ratio'), ...
        contains(string(systemAfter), 'recirculation start time'), ...
        contains(string(systemAfter), 'MR <= 0.1')));

% Ensure earlier drafted sections remain ready and later pending sections remain pending.
earlierReady = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

laterPending = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'MSD-POST-08', 'Earlier drafted sections remain draft-ready', ...
    earlierReady, sprintf('ready=%d', earlierReady));

Tchecks = addCheck(Tchecks, 'MSD-POST-09', 'Other genuine pending sections preserved', ...
    laterPending, sprintf('pendingPreserved=%d', laterPending));

Tchecks = addCheck(Tchecks, 'MSD-POST-10', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MSD-POST-11', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MSD-POST-12', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MSD-POST-13', 'No GA executed', ...
    true, 'Text-only System description draft');

Tchecks = addCheck(Tchecks, 'MSD-POST-14', 'No drying model executed', ...
    true, 'Text-only System description draft');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_SYSTEM_DESCRIPTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'MSD-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_SYSTEM_DESCRIPTION_DRAFT_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end

fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MSD-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_SYSTEM_DESCRIPTION_DRAFT_PASS';
decision = 'MASTER_UPDATED_WITH_SYSTEM_DESCRIPTION_DRAFT';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'System description drafted with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_SYSTEM_DESCRIPTION_DRAFT_DONE\n');

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
    fprintf(fid, 'MASTER HEADINGS DETECTED - SYSTEM DESCRIPTION DRAFT AFTER\n\n');
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
    fprintf(fid, '# MASTER_SYSTEM_DESCRIPTION_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-SYSTEM-DESCRIPTION-DRAFT-v96z-001`\n\n');
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
    fprintf('\nMASTER_SYSTEM_DESCRIPTION_DRAFT_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_SYSTEM_DESCRIPTION_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-SYSTEM-DESCRIPTION-DRAFT-v96z-001`\n\n');
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
