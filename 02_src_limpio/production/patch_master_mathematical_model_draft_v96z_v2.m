%% patch_master_mathematical_model_draft_v96z_v2.m
% 9.6z-draft-d
% MASTER-MATHEMATICAL-MODEL-DRAFT-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Draft # 5. Mathematical model in MASTER_manuscript_v01.md.
%
% Scope:
%   1. Replace Mathematical model scaffold with manuscript prose.
%   2. Update # 5 status to DRAFT_READY_FOR_REVIEW.
%   3. Describe the existing lumped-state dynamic model without changing equations,
%      parameters, numerical results, or optimization outputs.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not modify Abstract, Keywords, Introduction, System description,
%     Optimization methodology, Results, Discussion, Limitations, Conclusions,
%     Nomenclature, References, or Supplementary material.
%   - Does not invent citations.
%   - Does not introduce new physical correlations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER MATHEMATICAL MODEL DRAFT v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_MATHEMATICAL_MODEL_DRAFT_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_MATHEMATICAL_MODEL_DRAFT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_MATHEMATICAL_MODEL_DRAFT_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_mathematical_model_draft_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MMD-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MATHEMATICAL_MODEL_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MMD-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);
Tchecks = addCheck(Tchecks, 'MMD-PRE-03', 'Route-B order valid before Mathematical model draft', ...
    routeBOK, routeBEvidence(Headings));

idxModel = findHeadingExact(Headings, '# 5. Mathematical model');
idxOpt   = findHeadingExact(Headings, '# 6. Optimization methodology');

Tchecks = addCheck(Tchecks, 'MMD-PRE-04', '# 5 Mathematical model exists once', ...
    numel(idxModel) == 1, headingSummary(Headings, idxModel));

Tchecks = addCheck(Tchecks, 'MMD-PRE-05', '# 6 Optimization methodology exists once', ...
    numel(idxOpt) == 1, headingSummary(Headings, idxOpt));

modelSeg = sectionSegmentByHeading(txt, Headings, '# 5. Mathematical model');

Tchecks = addCheck(Tchecks, 'MMD-PRE-06', 'Mathematical model currently marked PENDING', ...
    contains(string(modelSeg), '`STATUS: PENDING`'), ...
    sprintf('present=%d', contains(string(modelSeg), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MMD-PRE-07', 'Mathematical model scaffold contains Expected content', ...
    contains(string(modelSeg), 'Expected content:'), ...
    sprintf('present=%d', contains(string(modelSeg), 'Expected content:')));

% Protect already-drafted previous sections.
prevReady = all([
    contains(string(sectionSegmentByHeading(txt, Headings, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 4. System description')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

Tchecks = addCheck(Tchecks, 'MMD-PRE-08', 'Previous sections already draft-ready', ...
    prevReady, sprintf('previousReady=%d', prevReady));

% Required manuscript/model anchors.
% v2: Only require anchors that must already exist in the manuscript.
% Product-temperature and structural-temperature wording may be introduced
% by this draft itself, so they are checked after reconstruction instead.
requiredAnchors = [
    "air temperature"
    "moisture ratio"
    "air mass flow rate"
    "minimum process temperature"
    "recirculation ratio"
    "recirculation start time"
    "Q_aux"
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

optionalModelTerms = [
    "product temperature"
    "structure temperature"
    "structural temperature"
    "product-temperature state"
    "structural-temperature state"
];

optionalEvidence = strings(numel(optionalModelTerms),1);
for k = 1:numel(optionalModelTerms)
    c = countLiteral(txt, char(optionalModelTerms(k)));
    optionalEvidence(k) = sprintf('%s=%d', optionalModelTerms(k), c);
end

Tchecks = addCheck(Tchecks, 'MMD-PRE-09', 'Required pre-existing model anchors acceptable before drafting', ...
    anchorsOK, join([anchorEvidence; optionalEvidence], ' | '));

preFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MATHEMATICAL_MODEL_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', ...
        'Precheck failed.');
end

%% Draft Mathematical model block

modelBlock = [
"# 5. Mathematical model" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"The dryer is represented by a lumped-state dynamic model that links process-air heating, product drying, structural thermal response, and auxiliary-energy demand. The model is used as the simulation core for the optimization workflow; it is not modified in this manuscript section. The purpose of this section is to document the state variables, inputs, operating logic, and performance indicators used by the existing implementation." newline newline ...
"The dynamic state vector includes four principal responses: process-air temperature, product temperature, product moisture ratio, and structural temperature. The air-temperature state represents the thermal condition of the drying stream entering and interacting with the product domain. The product-temperature state represents the thermal response of the material being dried. The moisture-ratio state is the drying-performance variable used to determine whether a simulated operating condition satisfies the final moisture criterion. The structural-temperature state accounts for the thermal inertia of the dryer structure and its interaction with the process air." newline newline ...
"The model receives time-dependent environmental and operational inputs associated with solar availability, ambient conditions, and the selected operating policy. The decision variables imposed by the optimization workflow are the air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. The air mass flow rate affects convective transport and residence-time behavior. The minimum process temperature defines the auxiliary-heating threshold. The recirculation ratio determines the fraction of outlet air returned to the process stream after recirculation begins. The recirculation start time determines when this air-reuse pathway is activated during the drying period." newline newline ...
"Hybrid operation is represented by combining the useful solar-air-heater contribution with LPG auxiliary heating. At each simulated condition, the solar subsystem contributes useful heat according to the selected collector-efficiency representation, while the auxiliary LPG system supplies the remaining thermal demand required to maintain the imposed minimum process temperature. The auxiliary-energy indicator Q_aux is therefore accumulated from the modeled thermal contribution assigned to the LPG heater. In the collector-efficiency sensitivity analysis, the same drying model is evaluated with the 2-SAH efficiency representation to test whether the selected operating-point ranking is preserved when the solar-air-heater assumption changes." newline newline ...
"The drying-performance criterion is based on the final moisture ratio. A candidate solution is considered feasible in this manuscript when the terminal value satisfies MR <= 0.1. Values substantially below this threshold indicate deeper drying, but not necessarily a preferable operating condition if the auxiliary-energy penalty is high. This distinction is important because the optimization and post-processing workflow compares feasible candidates by considering both moisture removal and energy demand rather than minimizing moisture ratio alone." newline newline ...
"The model outputs used in the manuscript include the terminal moisture ratio, auxiliary energy demand, and derived economic and CO2-related indicators. Economic and CO2 quantities are treated as post-processing indicators whose final interpretation depends on source-locked assumptions for prices, tariffs, emission factors, regional scope, unit basis, and conversion factors. Consequently, the dynamic model supports the operational comparison among selected candidates, but definitive techno-economic and environmental claims require final source validation." newline newline ...
"The mathematical model is used consistently for the R1 selected candidates, the historical H2 reference point, the collector-efficiency sensitivity, and the pointwise gas-LPG-only baseline comparison. The gas-LPG-only baseline preserves the selected decision-variable settings and suppresses the solar contribution, allowing Q_aux differences to be interpreted as the modeled auxiliary-energy reduction associated with hybrid operation under equivalent operating conditions." newline ...
];

modelBlock = char(join(string(modelBlock), ''));

%% Guard checks on draft block

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-01', 'Draft contains lumped-state dynamic model framing', ...
    contains(string(modelBlock), 'lumped-state dynamic model'), ...
    sprintf('present=%d', contains(string(modelBlock), 'lumped-state dynamic model')));

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-02', 'Draft contains four model states', ...
    all([contains(string(modelBlock), 'process-air temperature'), ...
         contains(string(modelBlock), 'product temperature'), ...
         contains(string(modelBlock), 'moisture ratio'), ...
         contains(string(modelBlock), 'structural temperature')]), ...
    sprintf('air=%d productT=%d MR=%d structure=%d', ...
        contains(string(modelBlock), 'process-air temperature'), ...
        contains(string(modelBlock), 'product temperature'), ...
        contains(string(modelBlock), 'moisture ratio'), ...
        contains(string(modelBlock), 'structural temperature')));

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-03', 'Draft contains decision variables', ...
    all([contains(string(modelBlock), 'air mass flow rate'), ...
         contains(string(modelBlock), 'minimum process temperature'), ...
         contains(string(modelBlock), 'recirculation ratio'), ...
         contains(string(modelBlock), 'recirculation start time')]), ...
    sprintf('mdot=%d Tmin=%d rrec=%d trec=%d', ...
        contains(string(modelBlock), 'air mass flow rate'), ...
        contains(string(modelBlock), 'minimum process temperature'), ...
        contains(string(modelBlock), 'recirculation ratio'), ...
        contains(string(modelBlock), 'recirculation start time')));

hasQaux_Draft = any(contains(string(modelBlock), 'Q_aux'));
hasLPG_Draft  = any(contains(string(modelBlock), 'LPG'));
Tchecks = addCheck(Tchecks, 'MMD-DRAFT-04', 'Draft contains Q_aux and LPG interpretation', ...
    hasQaux_Draft && hasLPG_Draft, ...
    sprintf('Qaux=%d LPG=%d', hasQaux_Draft, hasLPG_Draft));

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-05', 'Draft contains MR feasibility criterion', ...
    contains(string(modelBlock), 'MR <= 0.1'), ...
    sprintf('present=%d', contains(string(modelBlock), 'MR <= 0.1')));

has2SAH_Draft = any(contains(string(modelBlock), '2-SAH'));
hasSens_Draft = any(contains(lower(string(modelBlock)), 'sensitivity'));
Tchecks = addCheck(Tchecks, 'MMD-DRAFT-06', 'Draft contains 2-SAH sensitivity statement', ...
    has2SAH_Draft && hasSens_Draft, ...
    sprintf('2SAH=%d sensitivity=%d', has2SAH_Draft, hasSens_Draft));

hasSourceLocked_Draft = any(contains(string(modelBlock), 'source-locked assumptions'));
hasCO2_Draft = any(contains(string(modelBlock), 'CO2'));
Tchecks = addCheck(Tchecks, 'MMD-DRAFT-07', 'Draft keeps cost and CO2 conditional', ...
    hasSourceLocked_Draft && hasCO2_Draft, ...
    sprintf('sourceLocked=%d CO2=%d', hasSourceLocked_Draft, hasCO2_Draft));

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-08', 'Draft avoids equation invention markers', ...
    ~contains(string(modelBlock), 'dT/dt =') && ~contains(string(modelBlock), 'dMR/dt =') && ~contains(string(modelBlock), 'new correlation'), ...
    'No explicit new equations or correlations introduced');

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-09', 'Draft avoids citation placeholders', ...
    ~contains(string(modelBlock), 'CITATION_NEEDED') && ~contains(string(modelBlock), 'TODO') && ~contains(string(modelBlock), 'TBD'), ...
    'No citation placeholders in draft block');

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-10', 'Draft does not introduce unsupported global optimality claim', ...
    ~hasUnsupportedGlobalOptimumClaim(modelBlock), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(modelBlock)));

Tchecks = addCheck(Tchecks, 'MMD-DRAFT-11', 'Draft does not introduce unsupported statistical robustness claim', ...
    ~hasUnsupportedStatisticalRobustnessClaim(modelBlock), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(modelBlock)));

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MATHEMATICAL_MODEL_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft block failed guard checks.');
end

%% Reconstruct text

workTxt = replaceSectionByHeading(txt, Headings, '# 5. Mathematical model', modelBlock);
HeadingsAfter = detectCleanHeadings(workTxt);

%% Post reconstruction checks

routeBOKAfter = isRouteBOrderValid(HeadingsAfter);
Tchecks = addCheck(Tchecks, 'MMD-POST-01', 'Route-B order valid after Mathematical model reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

modelAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model');

Tchecks = addCheck(Tchecks, 'MMD-POST-02', 'Mathematical model status updated', ...
    contains(string(modelAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(modelAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'MMD-POST-03', 'Mathematical model PENDING marker removed', ...
    ~contains(string(modelAfter), '`STATUS: PENDING`'), ...
    sprintf('present=%d', contains(string(modelAfter), '`STATUS: PENDING`')));

Tchecks = addCheck(Tchecks, 'MMD-POST-04', 'Mathematical model Expected content scaffold removed', ...
    ~contains(string(modelAfter), 'Expected content:'), ...
    sprintf('present=%d', contains(string(modelAfter), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'MMD-POST-05', 'Mathematical model contains model states and decision variables', ...
    all([contains(string(modelAfter), 'process-air temperature'), ...
         contains(string(modelAfter), 'product temperature'), ...
         contains(string(modelAfter), 'moisture ratio'), ...
         contains(string(modelAfter), 'structural temperature'), ...
         contains(string(modelAfter), 'air mass flow rate'), ...
         contains(string(modelAfter), 'minimum process temperature'), ...
         contains(string(modelAfter), 'recirculation ratio'), ...
         contains(string(modelAfter), 'recirculation start time')]), ...
    sprintf('statesAndControlsPresent=%d', true));

hasQaux_Post = any(contains(string(modelAfter), 'Q_aux'));
hasMR_Post = any(contains(string(modelAfter), 'MR <= 0.1'));
Tchecks = addCheck(Tchecks, 'MMD-POST-06', 'Mathematical model contains Q_aux and MR criterion', ...
    hasQaux_Post && hasMR_Post, ...
    sprintf('Qaux=%d MR=%d', hasQaux_Post, hasMR_Post));

% Ensure earlier drafted sections remain ready and later pending sections remain pending.
earlierReady = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

laterPending = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'MMD-POST-07', 'Earlier drafted sections remain draft-ready', ...
    earlierReady, sprintf('ready=%d', earlierReady));

Tchecks = addCheck(Tchecks, 'MMD-POST-08', 'Other genuine pending sections preserved', ...
    laterPending, sprintf('pendingPreserved=%d', laterPending));

Tchecks = addCheck(Tchecks, 'MMD-POST-09', 'Optimization methodology remains PARTIAL', ...
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 6. Optimization methodology')), '`STATUS: PARTIAL`'), ...
    sprintf('partial=%d', contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 6. Optimization methodology')), '`STATUS: PARTIAL`')));

Tchecks = addCheck(Tchecks, 'MMD-POST-10', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MMD-POST-11', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MMD-POST-12', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MMD-POST-13', 'No GA executed', ...
    true, 'Text-only Mathematical model draft');

Tchecks = addCheck(Tchecks, 'MMD-POST-14', 'No drying model executed', ...
    true, 'Text-only Mathematical model draft');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MATHEMATICAL_MODEL_DRAFT_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'MMD-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_MATHEMATICAL_MODEL_DRAFT_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end

fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MMD-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_MATHEMATICAL_MODEL_DRAFT_PASS';
decision = 'MASTER_UPDATED_WITH_MATHEMATICAL_MODEL_DRAFT';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'Mathematical model drafted with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_MATHEMATICAL_MODEL_DRAFT_DONE\n');

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
    fprintf(fid, 'MASTER HEADINGS DETECTED - MATHEMATICAL MODEL DRAFT AFTER\n\n');
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
    fprintf(fid, '# MASTER_MATHEMATICAL_MODEL_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-MATHEMATICAL-MODEL-DRAFT-v96z-001`\n\n');
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
    fprintf('\nMASTER_MATHEMATICAL_MODEL_DRAFT_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_MATHEMATICAL_MODEL_DRAFT_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-MATHEMATICAL-MODEL-DRAFT-v96z-001`\n\n');
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
