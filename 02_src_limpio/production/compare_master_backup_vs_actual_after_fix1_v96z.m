%% compare_master_backup_vs_actual_after_fix1_v96z.m
% 9.6z-audit-c-diagnostic-b
% MASTER-BACKUP-VS-ACTUAL-COMPARISON-AFTER-FIX1-001
% READ_ONLY
%
% Purpose:
%   Compare the current MASTER manuscript against the pre-fix1 backup
%   created by patch_master_section_order_disc_lim_conc_v96z_fix1.m.
%
% This script:
%   - Reads MASTER current and backup only.
%   - Does not modify MASTER.
%   - Does not restore backup.
%   - Does not generate fix2.
%   - Does not run GA.
%   - Does not run the drying model.
%   - Writes a comparison report and CSV checks only.
%
% Diagnostic goal:
%   Decide whether restoration from the pre-fix1 backup is safer than
%   correcting the current MASTER after fix1 inserted blocks at the end.

clear; clc;

fprintf('\n=== MASTER BACKUP VS ACTUAL COMPARISON AFTER FIX1 v96z ===\n');

%% Paths

rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterCurrentPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

backupPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_20260703_161840.md');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

reportPath = fullfile(reviewDir, ...
    'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_Tchecks.csv');

headingsCurrentPath = fullfile(reviewDir, ...
    'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_current_headings.txt');

headingsBackupPath = fullfile(reviewDir, ...
    'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_backup_headings.txt');

%% Check helper

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = localAddCheck(Tchecks, 'CBFX1-01', 'Current MASTER exists', ...
    exist(masterCurrentPath, 'file') == 2, masterCurrentPath);

Tchecks = localAddCheck(Tchecks, 'CBFX1-02', 'Pre-fix1 backup exists', ...
    exist(backupPath, 'file') == 2, backupPath);

if exist(masterCurrentPath, 'file') ~= 2 || exist(backupPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('Required file missing. See checks CSV: %s', checksPath);
end

%% Read files

txtCurrent = fileread(masterCurrentPath);
txtBackup  = fileread(backupPath);

txtCurrent = localNormalizeNewlines(txtCurrent);
txtBackup  = localNormalizeNewlines(txtBackup);

Tchecks = localAddCheck(Tchecks, 'CBFX1-03', 'Current MASTER read successfully', ...
    strlength(string(txtCurrent)) > 0, sprintf('chars=%d', strlength(string(txtCurrent))));

Tchecks = localAddCheck(Tchecks, 'CBFX1-04', 'Backup MASTER read successfully', ...
    strlength(string(txtBackup)) > 0, sprintf('chars=%d', strlength(string(txtBackup))));

%% Build diagnostics for both files

Dcur = localDiagnoseText(txtCurrent, 'CURRENT');
Dbak = localDiagnoseText(txtBackup,  'BACKUP');

%% Write heading maps

localWriteHeadingMap(headingsCurrentPath, masterCurrentPath, Dcur.Headings, 'CURRENT MASTER');
localWriteHeadingMap(headingsBackupPath,  backupPath,        Dbak.Headings, 'PRE-FIX1 BACKUP');

%% Core preservation checks

Tchecks = localAddCheck(Tchecks, 'CBFX1-05', 'Current MASTER contains Section 7 heading', ...
    ~isnan(Dcur.posResults), sprintf('charpos=%g', Dcur.posResults));

Tchecks = localAddCheck(Tchecks, 'CBFX1-06', 'Backup contains Section 7 heading', ...
    ~isnan(Dbak.posResults), sprintf('charpos=%g', Dbak.posResults));

Tchecks = localAddCheck(Tchecks, 'CBFX1-07', 'Current contains Discussion internal key once', ...
    Dcur.nKeyDiscussion == 1, sprintf('count=%d charpos=%g', Dcur.nKeyDiscussion, Dcur.posKeyDiscussion));

Tchecks = localAddCheck(Tchecks, 'CBFX1-08', 'Backup contains Discussion internal key once', ...
    Dbak.nKeyDiscussion == 1, sprintf('count=%d charpos=%g', Dbak.nKeyDiscussion, Dbak.posKeyDiscussion));

Tchecks = localAddCheck(Tchecks, 'CBFX1-09', 'Current contains Limitations internal key once', ...
    Dcur.nKeyLimitations == 1, sprintf('count=%d charpos=%g', Dcur.nKeyLimitations, Dcur.posKeyLimitations));

Tchecks = localAddCheck(Tchecks, 'CBFX1-10', 'Backup contains Limitations internal key once', ...
    Dbak.nKeyLimitations == 1, sprintf('count=%d charpos=%g', Dbak.nKeyLimitations, Dbak.posKeyLimitations));

Tchecks = localAddCheck(Tchecks, 'CBFX1-11', 'Current contains Conclusions internal key once', ...
    Dcur.nKeyConclusions == 1, sprintf('count=%d charpos=%g', Dcur.nKeyConclusions, Dcur.posKeyConclusions));

Tchecks = localAddCheck(Tchecks, 'CBFX1-12', 'Backup contains Conclusions internal key once', ...
    Dbak.nKeyConclusions == 1, sprintf('count=%d charpos=%g', Dbak.nKeyConclusions, Dbak.posKeyConclusions));

%% Structural comparison checks

Tchecks = localAddCheck(Tchecks, 'CBFX1-13', 'Current References clean heading detected', ...
    Dcur.nReferencesClean == 1, sprintf('count=%d pos=%g summary=%s', Dcur.nReferencesClean, Dcur.posReferences, Dcur.refSummary));

Tchecks = localAddCheck(Tchecks, 'CBFX1-14', 'Backup References clean heading detected', ...
    Dbak.nReferencesClean == 1, sprintf('count=%d pos=%g summary=%s', Dbak.nReferencesClean, Dbak.posReferences, Dbak.refSummary));

Tchecks = localAddCheck(Tchecks, 'CBFX1-15', 'Current minimum order valid', ...
    Dcur.minimumOrderValid, Dcur.minimumOrderEvidence);

Tchecks = localAddCheck(Tchecks, 'CBFX1-16', 'Backup minimum order valid', ...
    Dbak.minimumOrderValid, Dbak.minimumOrderEvidence);

Tchecks = localAddCheck(Tchecks, 'CBFX1-17', 'Current has no residual 20# prefixes', ...
    Dcur.n20hash == 0, sprintf('20#_prefix_count=%d', Dcur.n20hash));

Tchecks = localAddCheck(Tchecks, 'CBFX1-18', 'Backup has no residual 20# prefixes', ...
    Dbak.n20hash == 0, sprintf('20#_prefix_count=%d', Dbak.n20hash));

Tchecks = localAddCheck(Tchecks, 'CBFX1-19', 'Current developed blocks are before References', ...
    Dcur.blocksBeforeReferences, Dcur.blocksBeforeReferencesEvidence);

Tchecks = localAddCheck(Tchecks, 'CBFX1-20', 'Backup developed blocks are before References', ...
    Dbak.blocksBeforeReferences, Dbak.blocksBeforeReferencesEvidence);

Tchecks = localAddCheck(Tchecks, 'CBFX1-21', 'Current internal developed block order is Discussion -> Limitations -> Conclusions', ...
    Dcur.internalKeyOrderValid, Dcur.internalKeyOrderEvidence);

Tchecks = localAddCheck(Tchecks, 'CBFX1-22', 'Backup internal developed block order is Discussion -> Limitations -> Conclusions', ...
    Dbak.internalKeyOrderValid, Dbak.internalKeyOrderEvidence);

%% Change evidence

lenDelta = strlength(string(txtCurrent)) - strlength(string(txtBackup));
Tchecks = localAddCheck(Tchecks, 'CBFX1-23', 'Current differs from backup', ...
    ~strcmp(txtCurrent, txtBackup), sprintf('char_delta_current_minus_backup=%d', lenDelta));

currentLooksPostFix1TailInsertion = ...
    Dcur.nKeyDiscussion == 1 && Dcur.nKeyLimitations == 1 && Dcur.nKeyConclusions == 1 && ...
    Dcur.posKeyLimitations < Dcur.posKeyDiscussion && Dcur.posKeyDiscussion < Dcur.posKeyConclusions;

Tchecks = localAddCheck(Tchecks, 'CBFX1-24', 'Current shows post-fix1 tail-insertion signature', ...
    currentLooksPostFix1TailInsertion, ...
    sprintf('LimitationsKey=%g DiscussionKey=%g ConclusionsKey=%g', ...
    Dcur.posKeyLimitations, Dcur.posKeyDiscussion, Dcur.posKeyConclusions));

backupHasAllTechnicalKeys = ...
    Dbak.nKeyDiscussion == 1 && Dbak.nKeyLimitations == 1 && Dbak.nKeyConclusions == 1;

Tchecks = localAddCheck(Tchecks, 'CBFX1-25', 'Backup appears technically complete for critical developed blocks', ...
    backupHasAllTechnicalKeys, ...
    sprintf('Discussion=%d Limitations=%d Conclusions=%d', ...
    Dbak.nKeyDiscussion, Dbak.nKeyLimitations, Dbak.nKeyConclusions));

%% Recommendation logic

restoreRecommended = backupHasAllTechnicalKeys && currentLooksPostFix1TailInsertion;
correctCurrentRecommended = ~restoreRecommended && ...
    Dcur.nKeyDiscussion == 1 && Dcur.nKeyLimitations == 1 && Dcur.nKeyConclusions == 1;

Tchecks = localAddCheck(Tchecks, 'CBFX1-26', 'Restore pre-fix1 backup is likely safer than correcting current', ...
    restoreRecommended, sprintf('restoreRecommended=%d correctCurrentRecommended=%d', ...
    restoreRecommended, correctCurrentRecommended));

failed = Tchecks(~Tchecks.pass, :);
if isempty(failed)
    diagnosis = 'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_PASS';
else
    diagnosis = 'MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_REVIEW_REQUIRED';
end

%% Write report

fid = fopen(reportPath, 'w');

fprintf(fid, '# MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z report\n\n');
fprintf(fid, '## Identifier\n\n');
fprintf(fid, '`MASTER-BACKUP-VS-ACTUAL-COMPARISON-AFTER-FIX1-001`\n\n');
fprintf(fid, '## Mode\n\n');
fprintf(fid, '`READ_ONLY`\n\n');
fprintf(fid, '## Diagnosis\n\n');
fprintf(fid, '`%s`\n\n', diagnosis);

fprintf(fid, '## Files\n\n');
fprintf(fid, '- Current MASTER: `%s`\n', masterCurrentPath);
fprintf(fid, '- Pre-fix1 backup: `%s`\n', backupPath);
fprintf(fid, '- Current headings: `%s`\n', headingsCurrentPath);
fprintf(fid, '- Backup headings: `%s`\n', headingsBackupPath);
fprintf(fid, '- Checks CSV: `%s`\n\n', checksPath);

fprintf(fid, '## Executive comparison\n\n');
fprintf(fid, '| item | current MASTER | pre-fix1 backup |\n');
fprintf(fid, '|---|---:|---:|\n');
fprintf(fid, '| Character count | %d | %d |\n', strlength(string(txtCurrent)), strlength(string(txtBackup)));
fprintf(fid, '| Clean headings | %d | %d |\n', height(Dcur.Headings), height(Dbak.Headings));
fprintf(fid, '| References clean heading count | %d | %d |\n', Dcur.nReferencesClean, Dbak.nReferencesClean);
fprintf(fid, '| Residual `20#` prefix count | %d | %d |\n', Dcur.n20hash, Dbak.n20hash);
fprintf(fid, '| Discussion internal key count | %d | %d |\n', Dcur.nKeyDiscussion, Dbak.nKeyDiscussion);
fprintf(fid, '| Limitations internal key count | %d | %d |\n', Dcur.nKeyLimitations, Dbak.nKeyLimitations);
fprintf(fid, '| Conclusions internal key count | %d | %d |\n', Dcur.nKeyConclusions, Dbak.nKeyConclusions);
fprintf(fid, '| Minimum order valid | %d | %d |\n', Dcur.minimumOrderValid, Dbak.minimumOrderValid);
fprintf(fid, '| Internal key order valid | %d | %d |\n\n', Dcur.internalKeyOrderValid, Dbak.internalKeyOrderValid);

fprintf(fid, '## Key positions\n\n');
fprintf(fid, '### Current MASTER\n\n');
localWritePositionsTable(fid, Dcur);
fprintf(fid, '\n### Pre-fix1 backup\n\n');
localWritePositionsTable(fid, Dbak);

fprintf(fid, '\n## Current MASTER evidence\n\n');
fprintf(fid, '- Minimum order evidence: `%s`\n', Dcur.minimumOrderEvidence);
fprintf(fid, '- Internal key order evidence: `%s`\n', Dcur.internalKeyOrderEvidence);
fprintf(fid, '- Blocks-before-References evidence: `%s`\n', Dcur.blocksBeforeReferencesEvidence);
fprintf(fid, '- Glued critical headings: `%s`\n', join(string(Dcur.gluedCrit), ' | '));
fprintf(fid, '- Glued headings anywhere: `%s`\n\n', join(string(Dcur.gluedAny), ' | '));

fprintf(fid, '## Backup evidence\n\n');
fprintf(fid, '- Minimum order evidence: `%s`\n', Dbak.minimumOrderEvidence);
fprintf(fid, '- Internal key order evidence: `%s`\n', Dbak.internalKeyOrderEvidence);
fprintf(fid, '- Blocks-before-References evidence: `%s`\n', Dbak.blocksBeforeReferencesEvidence);
fprintf(fid, '- Glued critical headings: `%s`\n', join(string(Dbak.gluedCrit), ' | '));
fprintf(fid, '- Glued headings anywhere: `%s`\n\n', join(string(Dbak.gluedAny), ' | '));

fprintf(fid, '## Failed checks\n\n');
if isempty(failed)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | check | evidence |\n');
    fprintf(fid, '|---|---|---|\n');
    for i = 1:height(failed)
        fprintf(fid, '| `%s` | %s | `%s` |\n', ...
            failed.id(i), failed.check(i), failed.evidence(i));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '## Decision support\n\n');
if restoreRecommended
    fprintf(fid, '`RESTORE_PREFIX1_BACKUP_LIKELY_SAFER_BEFORE_FIX2`\n\n');
    fprintf(fid, 'The current MASTER shows a post-fix1 tail-insertion signature, while the backup contains the critical developed block keys. A conservative fix2 should preferably start from the pre-fix1 backup after explicit user approval.\n\n');
elseif correctCurrentRecommended
    fprintf(fid, '`CORRECT_CURRENT_MASTER_MAY_BE_ACCEPTABLE_AFTER_EXPLICIT_APPROVAL`\n\n');
    fprintf(fid, 'The current MASTER contains the critical developed block keys, but restoration safety was not established by this diagnostic. A future fix should remain conservative and stop on ambiguity.\n\n');
else
    fprintf(fid, '`NO_SAFE_WRITE_RECOMMENDATION_FROM_THIS_DIAGNOSTIC`\n\n');
    fprintf(fid, 'The diagnostic did not establish a safe restoration or correction path. Manual inspection is required before writing.\n\n');
end

fprintf(fid, '## Next step\n\n');
fprintf(fid, 'Do not modify MASTER yet. Review this report first. If restoration is approved, create a separate restoration script that copies the backup to MASTER only after creating a new backup of the current post-fix1 MASTER.\n');

fclose(fid);

%% Write checks

writetable(Tchecks, checksPath);

%% Console summary

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Report:   %s\n', reportPath);
fprintf('Checks:   %s\n', checksPath);
fprintf('Current headings: %s\n', headingsCurrentPath);
fprintf('Backup headings:  %s\n', headingsBackupPath);

if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:, {'id','check','evidence'}));
end

if restoreRecommended
    fprintf('\nRecommendation: RESTORE_PREFIX1_BACKUP_LIKELY_SAFER_BEFORE_FIX2\n');
elseif correctCurrentRecommended
    fprintf('\nRecommendation: CORRECT_CURRENT_MASTER_MAY_BE_ACCEPTABLE_AFTER_EXPLICIT_APPROVAL\n');
else
    fprintf('\nRecommendation: NO_SAFE_WRITE_RECOMMENDATION_FROM_THIS_DIAGNOSTIC\n');
end

fprintf('\nMASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_DONE\n');

%% Local functions

function T = localAddCheck(T,id,check,pass,evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function txt = localNormalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
end

function D = localDiagnoseText(txt, label)
    lines = splitlines(string(txt));
    nLines = numel(lines);

    lineStart = zeros(nLines,1);
    pos = 1;
    for i = 1:nLines
        lineStart(i) = pos;
        pos = pos + strlength(lines(i)) + 1;
    end

    hLine = [];
    hChar = [];
    hHashes = strings(0,1);
    hLevel = [];
    hTitle = strings(0,1);
    hRaw = strings(0,1);

    for i = 1:nLines
        li = char(lines(i));
        tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            hLine(end+1,1) = i; %#ok<AGROW>
            hChar(end+1,1) = lineStart(i); %#ok<AGROW>
            hHashes(end+1,1) = string(tok{1}); %#ok<AGROW>
            hLevel(end+1,1) = strlength(string(tok{1})); %#ok<AGROW>
            hTitle(end+1,1) = string(tok{2}); %#ok<AGROW>
            hRaw(end+1,1) = string(li); %#ok<AGROW>
        end
    end

    Headings = table(hLine, hChar, hHashes, hLevel, hTitle, hRaw, ...
        'VariableNames', {'line','charpos','hashes','level','title','raw'});

    titleNorm = lower(strtrim(Headings.title));

    idxResults = find(contains(titleNorm, 'results and discussion'));
    idxDiscussion = find(strcmpi(strtrim(Headings.title), 'Discussion'));
    idxLimitations = find(strcmpi(strtrim(Headings.title), 'Limitations'));
    idxConclusions = find(strcmpi(strtrim(Headings.title), 'Conclusions'));
    idxReferences = find(strcmpi(strtrim(Headings.title), 'References'));

    posResults = localFirstChar(Headings, idxResults);
    posDiscussion = localFirstChar(Headings, idxDiscussion);
    posLimitations = localFirstChar(Headings, idxLimitations);
    posConclusions = localFirstChar(Headings, idxConclusions);
    posReferences = localFirstChar(Headings, idxReferences);

    keyDiscussion = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
    keyLimitations = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
    keyConclusions = 'This study developed a controlled multiobjective optimization and post-processing workflow';

    pD = strfind(txt, keyDiscussion);
    pL = strfind(txt, keyLimitations);
    pC = strfind(txt, keyConclusions);

    nKeyDiscussion = numel(pD);
    nKeyLimitations = numel(pL);
    nKeyConclusions = numel(pC);

    if isempty(pD), posKeyDiscussion = NaN; else, posKeyDiscussion = pD(1); end
    if isempty(pL), posKeyLimitations = NaN; else, posKeyLimitations = pL(1); end
    if isempty(pC), posKeyConclusions = NaN; else, posKeyConclusions = pC(1); end

    minimumOrderValid = all(~isnan([posResults posDiscussion posLimitations posConclusions posReferences])) && ...
        posResults < posDiscussion && posDiscussion < posLimitations && ...
        posLimitations < posConclusions && posConclusions < posReferences;

    minimumOrderEvidence = sprintf('Results=%g | Discussion=%g | Limitations=%g | Conclusions=%g | References=%g', ...
        posResults, posDiscussion, posLimitations, posConclusions, posReferences);

    internalKeyOrderValid = all(~isnan([posKeyDiscussion posKeyLimitations posKeyConclusions])) && ...
        posKeyDiscussion < posKeyLimitations && posKeyLimitations < posKeyConclusions;

    internalKeyOrderEvidence = sprintf('DiscussionKey=%g | LimitationsKey=%g | ConclusionsKey=%g', ...
        posKeyDiscussion, posKeyLimitations, posKeyConclusions);

    if isnan(posReferences)
        blocksBeforeReferences = false;
        blocksBeforeReferencesEvidence = 'References not detected as clean heading';
    else
        blocksBeforeReferences = all([posDiscussion posLimitations posConclusions] < posReferences);
        blocksBeforeReferencesEvidence = sprintf('DiscussionBeforeRef=%d | LimitationsBeforeRef=%d | ConclusionsBeforeRef=%d', ...
            posDiscussion < posReferences, posLimitations < posReferences, posConclusions < posReferences);
    end

    gluedCrit = regexp(txt, '[^\n]#{2,6}\s*(Discussion|Limitations|Conclusions|References)', 'match');
    gluedAny  = regexp(txt, '[^\n]#{1,6}\s+[^\n]+', 'match');
    n20hash = numel(regexp(txt, '20#{1,6}', 'match'));

    D.label = label;
    D.Headings = Headings;
    D.posResults = posResults;
    D.posDiscussion = posDiscussion;
    D.posLimitations = posLimitations;
    D.posConclusions = posConclusions;
    D.posReferences = posReferences;
    D.nReferencesClean = numel(idxReferences);
    D.discSummary = localHeadingSummary(Headings, idxDiscussion);
    D.limSummary = localHeadingSummary(Headings, idxLimitations);
    D.concSummary = localHeadingSummary(Headings, idxConclusions);
    D.refSummary = localHeadingSummary(Headings, idxReferences);
    D.nKeyDiscussion = nKeyDiscussion;
    D.nKeyLimitations = nKeyLimitations;
    D.nKeyConclusions = nKeyConclusions;
    D.posKeyDiscussion = posKeyDiscussion;
    D.posKeyLimitations = posKeyLimitations;
    D.posKeyConclusions = posKeyConclusions;
    D.minimumOrderValid = minimumOrderValid;
    D.minimumOrderEvidence = minimumOrderEvidence;
    D.internalKeyOrderValid = internalKeyOrderValid;
    D.internalKeyOrderEvidence = internalKeyOrderEvidence;
    D.blocksBeforeReferences = blocksBeforeReferences;
    D.blocksBeforeReferencesEvidence = blocksBeforeReferencesEvidence;
    D.gluedCrit = gluedCrit;
    D.gluedAny = gluedAny;
    D.n20hash = n20hash;
end

function p = localFirstChar(Headings, idx)
    if isempty(idx)
        p = NaN;
    else
        p = Headings.charpos(idx(1));
    end
end

function s = localHeadingSummary(Headings, idx)
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

function localWriteHeadingMap(path, sourcePath, Headings, label)
    fid = fopen(path, 'w');
    fprintf(fid, '%s - HEADINGS\n\n', label);
    fprintf(fid, 'SOURCE: %s\n\n', sourcePath);
    for i = 1:height(Headings)
        fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
            i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
    end
    fclose(fid);
end

function localWritePositionsTable(fid, D)
    fprintf(fid, '| item | char position | evidence |\n');
    fprintf(fid, '|---|---:|---|\n');
    fprintf(fid, '| Results and discussion | %.0f | `%s` |\n', D.posResults, localHeadingSummary(D.Headings, find(contains(lower(strtrim(D.Headings.title)), 'results and discussion'))));
    fprintf(fid, '| Discussion heading | %.0f | `%s` |\n', D.posDiscussion, D.discSummary);
    fprintf(fid, '| Limitations heading | %.0f | `%s` |\n', D.posLimitations, D.limSummary);
    fprintf(fid, '| Conclusions heading | %.0f | `%s` |\n', D.posConclusions, D.concSummary);
    fprintf(fid, '| References heading | %.0f | `%s` |\n', D.posReferences, D.refSummary);
    fprintf(fid, '| Discussion internal key | %.0f | `count=%d` |\n', D.posKeyDiscussion, D.nKeyDiscussion);
    fprintf(fid, '| Limitations internal key | %.0f | `count=%d` |\n', D.posKeyLimitations, D.nKeyLimitations);
    fprintf(fid, '| Conclusions internal key | %.0f | `count=%d` |\n', D.posKeyConclusions, D.nKeyConclusions);
end
