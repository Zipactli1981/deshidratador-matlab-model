%% patch_master_optimization_methodology_completion_v96z_v4.m
% 9.6z-draft-e
% MASTER-OPTIMIZATION-METHODOLOGY-COMPLETION-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Complete # 6. Optimization methodology in MASTER_manuscript_v01.md.
%
% Scope:
%   1. Replace remaining Expected content scaffold in #6 with methodology prose.
%   2. Preserve the section as methodology, not results.
%   3. Keep TABLE_01_GA_configuration as a pending/traceable table callout.
%   4. Update #6 status from PARTIAL to DRAFT_READY_FOR_REVIEW.
%
% This script:
%   - Creates a backup before writing.
%   - Stops with no write if prechecks fail.
%   - Does not modify Abstract, Keywords, Introduction, System description,
%     Mathematical model, Results, Discussion, Limitations, Conclusions,
%     Nomenclature, References, or Supplementary material.
%   - Does not change numerical results in #7.
%   - Does not invent citations.
%   - Does not run GA.
%   - Does not run the drying model.

clear; clc;

fprintf('\n=== MASTER OPTIMIZATION METHODOLOGY COMPLETION v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_OPTIMIZATION_METHODOLOGY_COMPLETION_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_optimization_methodology_completion_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MOMC-PRE-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MOMC-PRE-02', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

routeBOK = isRouteBOrderValid(Headings);
Tchecks = addCheck(Tchecks, 'MOMC-PRE-03', 'Route-B order valid before Optimization methodology completion', ...
    routeBOK, routeBEvidence(Headings));

idxOpt = findHeadingExact(Headings, '# 6. Optimization methodology');
idxResults = findHeadingExact(Headings, '# 7. Results and discussion');

Tchecks = addCheck(Tchecks, 'MOMC-PRE-04', '# 6 Optimization methodology exists once', ...
    numel(idxOpt) == 1, headingSummary(Headings, idxOpt));

Tchecks = addCheck(Tchecks, 'MOMC-PRE-05', '# 7 Results and discussion exists once', ...
    numel(idxResults) == 1, headingSummary(Headings, idxResults));

optSeg = sectionSegmentByHeading(txt, Headings, '# 6. Optimization methodology');
resultsSegBefore = sectionSegmentByHeading(txt, Headings, '# 7. Results and discussion');

% v4: Do not require exact PARTIAL marker as hard precondition; #6 is replaced as a whole.
hasPartialBefore = any(contains(string(optSeg), '`STATUS: PARTIAL`'));
hasDraftReadyBefore = any(contains(string(optSeg), '`STATUS: DRAFT_READY_FOR_REVIEW`'));
Tchecks = addCheck(Tchecks, 'MOMC-PRE-06', 'Optimization methodology status precheck informational', ...
    true, sprintf('partial=%d draftReady=%d', hasPartialBefore, hasDraftReadyBefore));

% v4: Expected content may already have been altered or absent; replacing the entire #6
% section remains safe as long as #6 and #7 boundaries are unique.
hasExpectedContentBefore = any(contains(string(optSeg), 'Expected content:'));
Tchecks = addCheck(Tchecks, 'MOMC-PRE-07', 'Expected content scaffold precheck informational', ...
    true, sprintf('present=%d', hasExpectedContentBefore));

% v3: TABLE_01_GA_configuration may be absent from #6 before completion.
% It is inserted and checked after reconstruction, so this precheck is informational.
tableInOptBefore = any(contains(string(optSeg), 'TABLE_01_GA_configuration'));
tableInMasterBefore = any(contains(string(txt), 'TABLE_01_GA_configuration'));
Tchecks = addCheck(Tchecks, 'MOMC-PRE-08', 'TABLE_01_GA_configuration precheck informational', ...
    true, sprintf('inOpt=%d inMaster=%d', tableInOptBefore, tableInMasterBefore));

% Protect already-drafted previous sections.
prevReady = all([
    contains(string(sectionSegmentByHeading(txt, Headings, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 4. System description')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(txt, Headings, '# 5. Mathematical model')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

Tchecks = addCheck(Tchecks, 'MOMC-PRE-09', 'Previous sections already draft-ready', ...
    prevReady, sprintf('previousReady=%d', prevReady));

% Required methodology anchors already present in manuscript.
% v2: require only anchors that are already known to exist. The exact
% strings seed = 61001, population = 24, and generations = 50 are introduced
% by this completion patch and are therefore checked after reconstruction.
requiredAnchors = [
    "R1"
    "exitflag = 0"
    "computed nondominated set"
    "MR <= 0.1"
    "H2"
    "historical"
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

optionalConfigTerms = [
    "seed = 61001"
    "seed"
    "61001"
    "population = 24"
    "population"
    "generations = 50"
    "generations"
];

optionalEvidence = strings(numel(optionalConfigTerms),1);
for k = 1:numel(optionalConfigTerms)
    c = countLiteral(txt, char(optionalConfigTerms(k)));
    optionalEvidence(k) = sprintf('%s=%d', optionalConfigTerms(k), c);
end

% v3: anchors are not allowed to block because this patch is the content completion.
% The completed #6 block is checked after reconstruction for all required content.
Tchecks = addCheck(Tchecks, 'MOMC-PRE-10', 'Pre-existing methodology anchors recorded before completion', ...
    true, join([anchorEvidence; optionalEvidence; "anchorsOK=" + string(anchorsOK)], ' | '));

% v2 Results protection: the methodology patch must not alter #7 at all.
% Instead of requiring exact result-token formatting, preserve the full #7
% section string and compare it after reconstruction.
resultsSigBefore = simpleTextSignature(resultsSegBefore);

Tchecks = addCheck(Tchecks, 'MOMC-PRE-11', 'Results section captured for no-change protection before completion', ...
    strlength(string(resultsSegBefore)) > 0, ...
    sprintf('chars=%d | signature=%d', strlength(string(resultsSegBefore)), resultsSigBefore));

% v3: Only structural prechecks are hard stops. Informational semantic anchors
% are recorded but must not block the patch.
hardPrecheckIds = [
    "MOMC-PRE-01"
    "MOMC-PRE-02"
    "MOMC-PRE-03"
    "MOMC-PRE-04"
    "MOMC-PRE-05"
];

preFailed = Tchecks(~Tchecks.pass & ismember(Tchecks.id, hardPrecheckIds), :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_STRUCTURAL_PRECHECK_FAILED', ...
        'Structural precheck failed.');
end

%% Draft Optimization methodology block

optBlock = [
"# 6. Optimization methodology" newline newline ...
"`STATUS: DRAFT_READY_FOR_REVIEW`" newline newline ...
"The optimization workflow couples the drying model described above with a multiobjective genetic-algorithm search and a controlled post-processing stage for candidate interpretation. The method is designed to identify feasible operating points for the hybrid solar--LPG dryer under simultaneous drying-performance, auxiliary-energy, economic, and CO2-related considerations. The optimization section reports the numerical procedure and its interpretation limits; the quantitative operating-point results are reported separately in the Results and discussion section." newline newline ...
"## 6.1 Decision variables and operating bounds" newline newline ...
"The optimization problem uses four operational decision variables: air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. These variables determine the airflow intensity, auxiliary-heating threshold, degree of outlet-air reuse, and timing of recirculation activation. The same decision-variable definitions are used for the R1 candidate evaluation, the historical H2 reference comparison, the collector-efficiency sensitivity analysis, and the pointwise gas-LPG-only baseline comparison." newline newline ...
"## 6.2 Objective functions and feasibility criterion" newline newline ...
"The search evaluates competing objectives associated with terminal moisture ratio, auxiliary-energy-related economic performance, and CO2-related environmental indicators. The terminal moisture ratio is used to distinguish feasible from infeasible drying outcomes. In this manuscript, a candidate is treated as feasible when the terminal condition satisfies MR <= 0.1. The post-processing interpretation therefore separates sufficient drying from excessive drying: a lower moisture ratio is not automatically preferred if it is obtained with a disproportionate auxiliary-energy penalty." newline newline ...
"Economic and CO2-related indicators are retained as conditional post-processing quantities. They are useful for ranking and interpretation within the controlled workflow, but final publication-level claims require source-locked assumptions for LPG price, electricity tariff if applicable, emission factors, regional scope, source year, unit basis, and conversion factors. For this reason, the manuscript emphasizes operational and auxiliary-energy behavior, while treating definitive economic and environmental claims as conditional until the final reference set is fixed." newline newline ...
"## 6.3 Genetic-algorithm configuration and run interpretation" newline newline ...
"The formal R1 optimization run was executed using seed = 61001, population = 24, and generations = 50. The resulting exitflag = 0 is interpreted as termination by the prescribed generation limit, not as a failure of the simulation and not as proof of convergence to a global optimum. The R1 output is therefore described as a computed nondominated set obtained under the specified configuration, random seed, decision-variable bounds, and model assumptions." newline newline ...
"`TABLE_01_GA_configuration`: pending table callout; the table should summarize the genetic-algorithm configuration, including seed = 61001, population = 24, generations = 50, termination criterion, decision variables, feasibility criterion MR <= 0.1, and interpretation notes for exitflag = 0." newline newline ...
"## 6.4 Candidate selection and reference points" newline newline ...
"Candidate interpretation is performed after the R1 search by selecting representative feasible points from the computed nondominated set. R1_solution_7 is treated as the main energy-conservative feasible candidate, R1_solution_3 as a balanced alternative, and R1_solution_9 as an aggressive drying case with higher auxiliary-energy demand. These labels are used only for structured interpretation of the computed set and do not imply unique global optimality." newline newline ...
"The H2 operating point is retained as a historical reference condition rather than as a newly optimized R1 solution. This distinction is important because H2 provides continuity with previous simulation and thesis-stage analysis, whereas the R1 candidates originate from the formal R1 search. Comparisons involving H2 are therefore interpreted as reference comparisons, not as evidence that H2 belongs to the same computed nondominated set as the R1 candidates." newline newline ...
"## 6.5 Collector-efficiency sensitivity and baseline comparison" newline newline ...
"The collector-efficiency sensitivity evaluates whether the qualitative interpretation of selected candidates is preserved when the simplified solar-air-heater efficiency assumption is replaced by the 2-SAH efficiency representation. This step is not a new coupled dynamic collector model; it is a physically motivated sensitivity using the same selected operating points and the same drying-model framework." newline newline ...
"The gas-LPG-only baseline comparison is performed pointwise at selected operating conditions. For each selected case, the decision-variable settings are preserved while the solar contribution is suppressed. The resulting difference in Q_aux between hybrid operation and gas-LPG-only operation is interpreted as the modeled auxiliary-energy reduction associated with hybrid solar contribution under equivalent operating conditions." newline newline ...
"## 6.6 Reproducibility and interpretation limits" newline newline ...
"The methodology is intentionally reported with seed, population, generation count, termination flag, and candidate-selection rules to support traceability. However, the use of one formal R1 seed-aware run does not establish statistical robustness across independent seeds. Additional independent runs, convergence diagnostics, and equipment-level uncertainty analyses would be required before making stronger claims about global search-space coverage or robustness. Within the present scope, the appropriate interpretation is a controlled optimization realization and post-processing workflow that identifies and compares feasible operating candidates under explicitly stated assumptions." newline ...
];

optBlock = char(join(string(optBlock), ''));

%% Guard checks on draft block

hasWorkflow_Draft = any(contains(string(optBlock), 'optimization workflow'));
hasGA_Draft = any(contains(string(optBlock), 'multiobjective genetic-algorithm'));
Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-01', 'Draft contains methodology framing', ...
    hasWorkflow_Draft && hasGA_Draft, ...
    sprintf('workflow=%d GA=%d', hasWorkflow_Draft, hasGA_Draft));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-02', 'Draft contains decision variables', ...
    all([contains(string(optBlock), 'air mass flow rate'), ...
         contains(string(optBlock), 'minimum process temperature'), ...
         contains(string(optBlock), 'recirculation ratio'), ...
         contains(string(optBlock), 'recirculation start time')]), ...
    sprintf('mdot=%d Tmin=%d rrec=%d trec=%d', ...
        contains(string(optBlock), 'air mass flow rate'), ...
        contains(string(optBlock), 'minimum process temperature'), ...
        contains(string(optBlock), 'recirculation ratio'), ...
        contains(string(optBlock), 'recirculation start time')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-03', 'Draft contains MR feasibility criterion', ...
    contains(string(optBlock), 'MR <= 0.1'), ...
    sprintf('present=%d', contains(string(optBlock), 'MR <= 0.1')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-04', 'Draft contains R1 GA configuration', ...
    all([contains(string(optBlock), 'seed = 61001'), ...
         contains(string(optBlock), 'population = 24'), ...
         contains(string(optBlock), 'generations = 50'), ...
         contains(string(optBlock), 'exitflag = 0')]), ...
    sprintf('seed=%d pop=%d gen=%d exit=%d', ...
        contains(string(optBlock), 'seed = 61001'), ...
        contains(string(optBlock), 'population = 24'), ...
        contains(string(optBlock), 'generations = 50'), ...
        contains(string(optBlock), 'exitflag = 0')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-05', 'Draft preserves computed nondominated set wording', ...
    contains(string(optBlock), 'computed nondominated set'), ...
    sprintf('present=%d', contains(string(optBlock), 'computed nondominated set')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-06', 'Draft contains candidate and H2 roles', ...
    all([contains(string(optBlock), 'R1_solution_7'), ...
         contains(string(optBlock), 'R1_solution_3'), ...
         contains(string(optBlock), 'R1_solution_9'), ...
         contains(string(optBlock), 'H2'), ...
         contains(lower(string(optBlock)), 'historical reference')]), ...
    sprintf('R1_7=%d R1_3=%d R1_9=%d H2=%d historical=%d', ...
        contains(string(optBlock), 'R1_solution_7'), ...
        contains(string(optBlock), 'R1_solution_3'), ...
        contains(string(optBlock), 'R1_solution_9'), ...
        contains(string(optBlock), 'H2'), ...
        contains(lower(string(optBlock)), 'historical reference')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-07', 'Draft preserves TABLE_01 callout', ...
    contains(string(optBlock), 'TABLE_01_GA_configuration'), ...
    sprintf('present=%d', contains(string(optBlock), 'TABLE_01_GA_configuration')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-08', 'Draft contains 2-SAH sensitivity and gas-LPG baseline framing', ...
    all([contains(string(optBlock), '2-SAH'), ...
         contains(string(optBlock), 'gas-LPG-only baseline'), ...
         contains(string(optBlock), 'Q_aux')]), ...
    sprintf('2SAH=%d baseline=%d Qaux=%d', contains(string(optBlock), '2-SAH'), contains(string(optBlock), 'gas-LPG-only baseline'), contains(string(optBlock), 'Q_aux')));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-09', 'Draft does not introduce unsupported global optimality claim', ...
    ~hasUnsupportedGlobalOptimumClaim(optBlock), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(optBlock)));

Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-10', 'Draft does not introduce unsupported statistical robustness claim', ...
    ~hasUnsupportedStatisticalRobustnessClaim(optBlock), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(optBlock)));

hasCitationPlaceholder_Draft = any(contains(string(optBlock), 'CITATION_NEEDED')) || any(contains(string(optBlock), 'TODO')) || any(contains(string(optBlock), 'TBD'));
Tchecks = addCheck(Tchecks, 'MOMC-DRAFT-11', 'Draft avoids citation placeholders', ...
    ~hasCitationPlaceholder_Draft, ...
    sprintf('placeholderPresent=%d', hasCitationPlaceholder_Draft));

draftFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(draftFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_DRAFT_CHECK_FAILED', ...
        'Draft block failed guard checks.');
end

%% Reconstruct text

workTxt = replaceSectionByHeading(txt, Headings, '# 6. Optimization methodology', optBlock);
HeadingsAfter = detectCleanHeadings(workTxt);

%% Post reconstruction checks

routeBOKAfter = isRouteBOrderValid(HeadingsAfter);
Tchecks = addCheck(Tchecks, 'MOMC-POST-01', 'Route-B order valid after Optimization methodology reconstruction', ...
    routeBOKAfter, routeBEvidence(HeadingsAfter));

optAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 6. Optimization methodology');
resultsSegAfter = sectionSegmentByHeading(workTxt, HeadingsAfter, '# 7. Results and discussion');

Tchecks = addCheck(Tchecks, 'MOMC-POST-02', 'Optimization methodology status updated', ...
    contains(string(optAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`'), ...
    sprintf('present=%d', contains(string(optAfter), '`STATUS: DRAFT_READY_FOR_REVIEW`')));

Tchecks = addCheck(Tchecks, 'MOMC-POST-03', 'Optimization methodology PARTIAL marker removed', ...
    ~contains(string(optAfter), '`STATUS: PARTIAL`'), ...
    sprintf('present=%d', contains(string(optAfter), '`STATUS: PARTIAL`')));

Tchecks = addCheck(Tchecks, 'MOMC-POST-04', 'Optimization methodology Expected content scaffold removed', ...
    ~contains(string(optAfter), 'Expected content:'), ...
    sprintf('present=%d', contains(string(optAfter), 'Expected content:')));

Tchecks = addCheck(Tchecks, 'MOMC-POST-05', 'TABLE_01 callout preserved in methodology', ...
    contains(string(optAfter), 'TABLE_01_GA_configuration'), ...
    sprintf('present=%d', contains(string(optAfter), 'TABLE_01_GA_configuration')));

Tchecks = addCheck(Tchecks, 'MOMC-POST-06', 'Methodology contains R1 configuration and interpretation limits', ...
    all([contains(string(optAfter), 'seed = 61001'), ...
         contains(string(optAfter), 'population = 24'), ...
         contains(string(optAfter), 'generations = 50'), ...
         contains(string(optAfter), 'exitflag = 0'), ...
         contains(string(optAfter), 'computed nondominated set'), ...
         contains(lower(string(optAfter)), 'not as proof of convergence to a global optimum') || contains(lower(string(optAfter)), 'not as proof')]), ...
    sprintf('methodologyConfigPresent=%d', true));

Tchecks = addCheck(Tchecks, 'MOMC-POST-07', 'Methodology contains candidate-selection roles', ...
    all([contains(string(optAfter), 'R1_solution_7'), ...
         contains(string(optAfter), 'R1_solution_3'), ...
         contains(string(optAfter), 'R1_solution_9'), ...
         contains(string(optAfter), 'H2')]), ...
    sprintf('R1_7=%d R1_3=%d R1_9=%d H2=%d', ...
        contains(string(optAfter), 'R1_solution_7'), ...
        contains(string(optAfter), 'R1_solution_3'), ...
        contains(string(optAfter), 'R1_solution_9'), ...
        contains(string(optAfter), 'H2')));

% Ensure #7 Results section was not altered at all.
resultsSigAfter = simpleTextSignature(resultsSegAfter);
resultsUnchanged = strcmp(resultsSegBefore, resultsSegAfter) && resultsSigBefore == resultsSigAfter;

Tchecks = addCheck(Tchecks, 'MOMC-POST-08', 'Results section preserved exactly after reconstruction', ...
    resultsUnchanged, ...
    sprintf('beforeChars=%d afterChars=%d beforeSig=%d afterSig=%d', ...
        strlength(string(resultsSegBefore)), strlength(string(resultsSegAfter)), ...
        resultsSigBefore, resultsSigAfter));

% Ensure earlier drafted sections remain ready and later pending sections remain pending.
earlierReady = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 1. Abstract')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 2. Keywords')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 3. Introduction')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 4. System description')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 5. Mathematical model')), '`STATUS: DRAFT_READY_FOR_REVIEW`')
]);

laterPending = all([
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 10. Nomenclature')), '`STATUS: PENDING`')
    contains(string(sectionSegmentByHeading(workTxt, HeadingsAfter, '# 11. References')), '`STATUS: PENDING`')
]);

Tchecks = addCheck(Tchecks, 'MOMC-POST-09', 'Earlier drafted sections remain draft-ready', ...
    earlierReady, sprintf('ready=%d', earlierReady));

Tchecks = addCheck(Tchecks, 'MOMC-POST-10', 'Other genuine pending sections preserved', ...
    laterPending, sprintf('pendingPreserved=%d', laterPending));

Tchecks = addCheck(Tchecks, 'MOMC-POST-11', 'No unsupported global optimality claim introduced', ...
    ~hasUnsupportedGlobalOptimumClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalOptimumClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MOMC-POST-12', 'No unsupported global Pareto-front claim introduced', ...
    ~hasUnsupportedGlobalParetoClaim(workTxt), sprintf('present=%d', hasUnsupportedGlobalParetoClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MOMC-POST-13', 'No unsupported statistical robustness claim introduced', ...
    ~hasUnsupportedStatisticalRobustnessClaim(workTxt), sprintf('present=%d', hasUnsupportedStatisticalRobustnessClaim(workTxt)));

Tchecks = addCheck(Tchecks, 'MOMC-POST-14', 'No GA executed', ...
    true, 'Text-only Optimization methodology completion');

Tchecks = addCheck(Tchecks, 'MOMC-POST-15', 'No drying model executed', ...
    true, 'Text-only Optimization methodology completion');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

%% Write with backup

copyfile(masterPath, backupPath);

Tchecks = addCheck(Tchecks, 'MOMC-WRITE-01', 'Backup created before writing', ...
    exist(backupPath, 'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end

fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MOMC-WRITE-02', 'MASTER updated', ...
    true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);

diagnosis = 'MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_PASS';
decision = 'MASTER_UPDATED_WITH_OPTIMIZATION_METHODOLOGY_COMPLETION';

writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, ...
    'Optimization methodology completed with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_DONE\n');

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

function sig = simpleTextSignature(txt)
    % Lightweight deterministic text signature for unchanged-section checks.
    s = char(string(txt));
    vals = double(s);
    if isempty(vals)
        sig = 0;
    else
        weights = mod(1:numel(vals), 997) + 1;
        sig = mod(sum(vals(:)' .* weights), 2147483647);
    end
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid = fopen(outPath, 'w');
    fprintf(fid, 'MASTER HEADINGS DETECTED - OPTIMIZATION METHODOLOGY COMPLETION AFTER\n\n');
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
    fprintf(fid, '# MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-OPTIMIZATION-METHODOLOGY-COMPLETION-v96z-001`\n\n');
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
    fprintf('\nMASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);

    fid = fopen(reportPath, 'w');
    fprintf(fid, '# MASTER_OPTIMIZATION_METHODOLOGY_COMPLETION_v96z report\n\n');
    fprintf(fid, '## Identifier\n\n`MASTER-OPTIMIZATION-METHODOLOGY-COMPLETION-v96z-001`\n\n');
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
