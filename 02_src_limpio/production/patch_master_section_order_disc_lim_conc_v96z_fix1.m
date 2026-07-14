function out = patch_master_section_order_disc_lim_conc_v96z_fix1()
% Fix1: normaliza encabezados pegados tipo "20### Discussion" y reordena.
% No ejecuta GA/modelo.

rootDir = setup_v05_paths();
articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
draftDir = fullfile(articleRoot,'draft_sections');
reviewDir = fullfile(articleRoot,'review');
traceDir = fullfile(articleRoot,'traceability');
lockDir = fullfile(articleRoot,'locked_sections');

if ~isfolder(reviewDir), mkdir(reviewDir); end
if ~isfolder(traceDir), mkdir(traceDir); end

masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
patchReport = fullfile(reviewDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1_report.md');
patchChecks = fullfile(reviewDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1_Tchecks.csv');
headingsBefore = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_before.txt');
headingsAfter = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_after.txt');
traceMat = fullfile(traceDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1.mat');

if ~isfile(masterFile), error('MASTER not found: %s',masterFile); end

masterBefore = fileread(masterFile);
section7Before = extract_section7_flexible(masterBefore);
write_headings_report(masterBefore,headingsBefore);

backupFile = fullfile(draftDir, ['MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);
copyfile(masterFile,backupFile);

discussionKey = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
limitationsKey = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
conclusionsKey = 'This study developed a controlled multiobjective optimization and post-processing workflow';

normalized = normalize_glued_headings(masterBefore);

[discSpan, discBlock] = get_block_by_heading_and_key(normalized,'Discussion',discussionKey);
[limSpan, limBlock] = get_block_by_heading_and_key(normalized,'Limitations',limitationsKey);
[concSpan, concBlock] = get_block_by_heading_and_key(normalized,'Conclusions',conclusionsKey);

haveBlocks = all(~isnan([discSpan limSpan concSpan]));

if ~haveBlocks
    masterAfter = normalized;
    patchAction = "NO_WRITE_MISSING_REQUIRED_BLOCK";
    locationEvidence = "Could not robustly detect all three blocks after glued-heading normalization.";
else
    spans = [discSpan; limSpan; concSpan];
    [~,ord] = sort(spans(:,1),'descend');
    masterClean = normalized;
    for k = 1:numel(ord)
        s = spans(ord(k),1); e = spans(ord(k),2);
        masterClean = [masterClean(1:s-1) masterClean(e+1:end)];
    end
    masterClean = regexprep(masterClean,'\n{4,}','\n\n\n');
    combinedBlock = char(newline + string(strtrim(discBlock)) + newline + newline + string(strtrim(limBlock)) + newline + newline + string(strtrim(concBlock)) + newline);
    idxRef = regexp(masterClean,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start','once');
    if ~isempty(idxRef)
        insertIdx = idxRef;
        locationEvidence = "Reinserted Discussion -> Limitations -> Conclusions before References after normalizing glued headings.";
    else
        insertIdx = length(masterClean) + 1;
        locationEvidence = "Reinserted Discussion -> Limitations -> Conclusions at end because References was not detected.";
    end
    masterAfter = [masterClean(1:insertIdx-1) combinedBlock masterClean(insertIdx:end)];
    fid = fopen(masterFile,'w'); if fid < 0, error('Could not write MASTER'); end
    fprintf(fid,'%s',masterAfter); fclose(fid);
    patchAction = "MASTER_UPDATED";
end

masterAfterRead = fileread(masterFile);
write_headings_report(masterAfterRead,headingsAfter);
lowAfter = lower(string(masterAfterRead));
section7After = extract_section7_flexible(masterAfterRead);
section7OK = true;
if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
    section7OK = strcmp(section7Before,section7After);
end
orderOK = section_order_ok(masterAfterRead);
noGluedCritical = isempty(regexp(masterAfterRead,'(?m).+###\s*(?:Discussion|Limitations|Conclusions)\s*$','once'));

checks = {};
checks{end+1,1}=ck("SFX1-01","MASTER exists",isfile(masterFile),masterFile);
checks{end+1,1}=ck("SFX1-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
checks{end+1,1}=ck("SFX1-03","Backup created",isfile(backupFile),backupFile);
checks{end+1,1}=ck("SFX1-04","Headings before report created",isfile(headingsBefore),headingsBefore);
checks{end+1,1}=ck("SFX1-05","Headings after report created",isfile(headingsAfter),headingsAfter);
checks{end+1,1}=ck("SFX1-06","Discussion detected after normalization",~isnan(discSpan(1)),"Discussion span");
checks{end+1,1}=ck("SFX1-07","Limitations detected after normalization",~isnan(limSpan(1)),"Limitations span");
checks{end+1,1}=ck("SFX1-08","Conclusions detected after normalization",~isnan(concSpan(1)),"Conclusions span");
checks{end+1,1}=ck("SFX1-09","Patch action valid",patchAction=="MASTER_UPDATED" || patchAction=="NO_WRITE_MISSING_REQUIRED_BLOCK",patchAction);
checks{end+1,1}=ck("SFX1-10","Discussion key present once",count(string(masterAfterRead),discussionKey)==1,"Discussion key count");
checks{end+1,1}=ck("SFX1-11","Limitations key present once",count(string(masterAfterRead),limitationsKey)==1,"Limitations key count");
checks{end+1,1}=ck("SFX1-12","Conclusions key present once",count(string(masterAfterRead),conclusionsKey)==1,"Conclusions key count");
checks{end+1,1}=ck("SFX1-13","Discussion title present once",count(string(masterAfterRead),"### Discussion")==1,"Discussion title count");
checks{end+1,1}=ck("SFX1-14","Limitations title present once",count(string(masterAfterRead),"### Limitations")==1,"Limitations title count");
checks{end+1,1}=ck("SFX1-15","Conclusions title present once",count(string(masterAfterRead),"### Conclusions")==1,"Conclusions title count");
checks{end+1,1}=ck("SFX1-16","No glued critical headings remain",noGluedCritical,"No text immediately before ### critical headings");
checks{end+1,1}=ck("SFX1-17","Minimum section order valid",orderOK,"Results -> Discussion -> Limitations -> Conclusions -> References");
checks{end+1,1}=ck("SFX1-18","Section 7 preserved when detectable",section7OK,"Section 7 comparison");
checks{end+1,1}=ck("SFX1-19","No prohibited global optimum wording",~contains(lowAfter,"global optimum") && ~contains(lowAfter,"globally optimal"),"No prohibited wording");
checks{end+1,1}=ck("SFX1-20","No prohibited global Pareto front wording",~contains(lowAfter,"global pareto front"),"No prohibited wording");
checks{end+1,1}=ck("SFX1-21","No statistical robustness claim",~contains(lowAfter,"statistically robust") && ~contains(lowAfter,"robust across seeds"),"No overclaim");
checks{end+1,1}=ck("SFX1-22","No final CO2 claim",~contains(lowAfter,"final co2 reduction") && ~contains(lowAfter,"final emission reduction") && ~contains(lowAfter,"definitive emission reduction"),"No final CO2 claim");
checks{end+1,1}=ck("SFX1-23","No final cost claim",~contains(lowAfter,"final cost reduction") && ~contains(lowAfter,"final economic saving") && ~contains(lowAfter,"definitive economic saving"),"No final cost claim");
checks{end+1,1}=ck("SFX1-24","No GA executed",true,"Text normalization/reordering only");
checks{end+1,1}=ck("SFX1-25","No model executed",true,"Text normalization/reordering only");

Tchecks = struct2table(vertcat(checks{:}));
writetable(Tchecks,patchChecks);

if all(Tchecks.pass)
    diagnosis = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_FIX1_PASS";
    decision = "RERUN_MASTER_AFTER_CONCLUSIONS_AUDIT";
    next_step = "Re-run audit_master_after_conclusions_v96z.";
else
    diagnosis = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_FIX1_REVIEW_REQUIRED";
    decision = "INSPECT_FAILED_CHECKS";
    next_step = "Inspect failed checks and headings reports before modifying again.";
end

fid = fopen(patchReport,'w');
fprintf(fid,'# PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1 report\n\n');
fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
fprintf(fid,'## Patch action\n\n`%s`\n\n',patchAction);
fprintf(fid,'## Location evidence\n\n`%s`\n\n',locationEvidence);
fprintf(fid,'## Root cause\n\nCritical headings were present but glued to preceding text, e.g. `20### Discussion`; strict Markdown extraction failed.\n\n');
fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings before: `%s`\n- Headings after: `%s`\n\n',masterFile,backupFile,patchChecks,headingsBefore,headingsAfter);
fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
for i=1:height(Tchecks)
    fprintf(fid,'| `%s` | %s | %d | `%s` |\n',string(Tchecks.id(i)),string(Tchecks.check(i)),Tchecks.pass(i),string(Tchecks.evidence(i)));
end
fclose(fid);

save(traceMat,'masterFile','lockedSection7','backupFile','patchReport','patchChecks','headingsBefore','headingsAfter','traceMat','Tchecks','diagnosis','decision','next_step','patchAction','locationEvidence','discSpan','limSpan','concSpan');

out = struct();
out.status = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1_DONE";
out.diagnosis = diagnosis;
out.decision = decision;
out.next_step = next_step;
out.patchAction = patchAction;
out.locationEvidence = locationEvidence;
out.masterFile = masterFile;
out.backupFile = backupFile;
out.patchReport = patchReport;
out.patchChecks = patchChecks;
out.headingsBefore = headingsBefore;
out.headingsAfter = headingsAfter;
out.traceMat = traceMat;
out.Tchecks = Tchecks;

disp('=== PATCH MASTER SECTION ORDER DISCUSSION LIMITATIONS CONCLUSIONS v96z fix1 ===')
disp(out.status); disp(out.diagnosis); disp(out.decision); disp(out.next_step)
disp(out.patchAction); disp(out.locationEvidence)
disp(out.Tchecks(~out.Tchecks.pass,:))
end

function txt2 = normalize_glued_headings(txt)
txt2 = regexprep(txt,'([^\n])(\#{1,6}\s*(?:Discussion|Limitations|Conclusions)\s*)','$1\n$2');
txt2 = regexprep(txt2,'(?m)^20(\#{1,6}\s*(?:Discussion|Limitations|Conclusions)\s*)','$1');
end

function [span, block] = get_block_by_heading_and_key(txt,sectionName,key)
idxKey = strfind(txt,key);
if isempty(idxKey), span=[NaN NaN]; block=""; return; end
idxKey = idxKey(1);
pat = "(?m)^#{1,6}\s*" + string(sectionName) + "\s*$";
h = regexp(txt,pat,'start');
h = h(h < idxKey);
if isempty(h), span=[NaN NaN]; block=""; return; end
s = h(end);
rest = txt(s+1:end);
n = regexp(rest,'(?m)^#{1,6}\s+.*$','start','once');
if isempty(n), e=length(txt); else, e=s+n-1; end
span=[s e]; block=txt(s:e);
end

function tf = section_order_ok(txt)
idxRes = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','start');
idxDisc = regexp(txt,'(?m)^#{1,6}\s*Discussion\s*$','start');
idxLim = regexp(txt,'(?m)^#{1,6}\s*Limitations\s*$','start');
idxConc = regexp(txt,'(?m)^#{1,6}\s*Conclusions\s*$','start');
idxRef = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start');
tf = true;
if ~isempty(idxRes) && ~isempty(idxDisc), tf = tf && idxRes(1)<idxDisc(1); end
if ~isempty(idxDisc) && ~isempty(idxLim), tf = tf && idxDisc(1)<idxLim(1); end
if ~isempty(idxLim) && ~isempty(idxConc), tf = tf && idxLim(1)<idxConc(1); end
if ~isempty(idxConc) && ~isempty(idxRef), tf = tf && idxConc(1)<idxRef(1); end
end

function s7 = extract_section7_flexible(txt)
idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once');
if isempty(idxStart), s7=''; return; end
rest = txt(idxStart+1:end);
idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Limitations\b|Conclusions\b|Conclusion\b|Conclusiones\b|References\b|Referencias\b).*$','once');
if isempty(idxNext), s7=txt(idxStart:end); else, s7=txt(idxStart:idxStart+idxNext-1); end
end

function write_headings_report(txt,filename)
[starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
fid = fopen(filename,'w');
fprintf(fid,'MASTER headings detected\n\n');
if isempty(matches)
    fprintf(fid,'No Markdown headings detected.\n');
else
    for i=1:numel(matches)
        fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
    end
end
fclose(fid);
end

function r = ck(id,checkName,passVal,evidence)
r = struct(); r.id=string(id); r.check=string(checkName); r.pass=logical(passVal); r.evidence=string(evidence);
end
