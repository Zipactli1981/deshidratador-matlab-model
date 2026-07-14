function out = patch_master_section_order_disc_lim_conc_v96z()
% PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z
% Reordena Discussion, Limitations y Conclusions en MASTER.
% No ejecuta GA ni modelo.

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

    patchReport = fullfile(reviewDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_report.md');
    patchChecks = fullfile(reviewDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_section_order_patch.txt');
    traceMat = fullfile(traceDir,'PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    write_headings_report(masterBefore,headingsReport);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);
    copyfile(masterFile,backupFile);

    [discSpan, discBlock] = get_section_span(masterBefore,"Discussion");
    [limSpan, limBlock] = get_section_span(masterBefore,"Limitations");
    [concSpan, concBlock] = get_section_span(masterBefore,"Conclusions");

    haveBlocks = all(~isnan([discSpan limSpan concSpan]));

    if ~haveBlocks
        masterAfter = masterBefore;
        patchAction = "NO_WRITE_MISSING_REQUIRED_BLOCK";
        locationEvidence = "Could not detect all three blocks: Discussion, Limitations, Conclusions.";
    else
        spans = [discSpan; limSpan; concSpan];
        [~,ord] = sort(spans(:,1),'descend');

        masterClean = masterBefore;
        for k = 1:numel(ord)
            s = spans(ord(k),1);
            e = spans(ord(k),2);
            masterClean = [masterClean(1:s-1) masterClean(e+1:end)];
        end

        masterClean = regexprep(masterClean,'\n{4,}','\n\n\n');

        combinedBlock = char(newline + string(strtrim(discBlock)) + newline + newline + ...
                             string(strtrim(limBlock)) + newline + newline + ...
                             string(strtrim(concBlock)) + newline);

        idxRef = regexp(masterClean,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start','once');

        if ~isempty(idxRef)
            insertIdx = idxRef;
            locationEvidence = "Reinserted Discussion -> Limitations -> Conclusions before References.";
        else
            insertIdx = length(masterClean) + 1;
            locationEvidence = "Reinserted Discussion -> Limitations -> Conclusions at end because References was not detected.";
        end

        masterAfter = [masterClean(1:insertIdx-1) combinedBlock masterClean(insertIdx:end)];

        fid = fopen(masterFile,'w');
        if fid < 0
            error('Could not open MASTER for writing: %s',masterFile);
        end
        fprintf(fid,'%s',masterAfter);
        fclose(fid);

        patchAction = "MASTER_UPDATED";
    end

    masterAfterRead = fileread(masterFile);
    lowAfter = lower(string(masterAfterRead));
    section7After = extract_section7_flexible(masterAfterRead);

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    orderOK = section_order_ok(masterAfterRead);

    discussionKey = "The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate";
    limitationsKey = "Several limitations must be considered when interpreting the optimization and baseline-comparison results";
    conclusionsKey = "This study developed a controlled multiobjective optimization and post-processing workflow";

    checks = {};
    checks{end+1,1} = check_row("SORD-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("SORD-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("SORD-03","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("SORD-04","Headings diagnostic report created",isfile(headingsReport),headingsReport);
    checks{end+1,1} = check_row("SORD-05","Discussion block detected before patch",~isnan(discSpan(1)),"Discussion span.");
    checks{end+1,1} = check_row("SORD-06","Limitations block detected before patch",~isnan(limSpan(1)),"Limitations span.");
    checks{end+1,1} = check_row("SORD-07","Conclusions block detected before patch",~isnan(concSpan(1)),"Conclusions span.");
    checks{end+1,1} = check_row("SORD-08","Patch action valid",patchAction=="MASTER_UPDATED" || patchAction=="NO_WRITE_MISSING_REQUIRED_BLOCK",patchAction);
    checks{end+1,1} = check_row("SORD-09","Discussion key present once",count(string(masterAfterRead),discussionKey)==1,"Discussion key count.");
    checks{end+1,1} = check_row("SORD-10","Limitations key present once",count(string(masterAfterRead),limitationsKey)==1,"Limitations key count.");
    checks{end+1,1} = check_row("SORD-11","Conclusions key present once",count(string(masterAfterRead),conclusionsKey)==1,"Conclusions key count.");
    checks{end+1,1} = check_row("SORD-12","Discussion title present once",count(string(masterAfterRead),"### Discussion")==1,"Discussion title count.");
    checks{end+1,1} = check_row("SORD-13","Limitations title present once",count(string(masterAfterRead),"### Limitations")==1,"Limitations title count.");
    checks{end+1,1} = check_row("SORD-14","Conclusions title present once",count(string(masterAfterRead),"### Conclusions")==1,"Conclusions title count.");
    checks{end+1,1} = check_row("SORD-15","Minimum section order valid",orderOK,"Expected Results -> Discussion -> Limitations -> Conclusions -> References when detectable.");
    checks{end+1,1} = check_row("SORD-16","Section 7 preserved when detectable",section7ProtectionOK,"Section 7 comparison flexible.");
    checks{end+1,1} = check_row("SORD-17","No prohibited global optimum wording",~contains(lowAfter,"global optimum") && ~contains(lowAfter,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("SORD-18","No prohibited global Pareto front wording",~contains(lowAfter,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("SORD-19","No statistical robustness claim",~contains(lowAfter,"statistically robust") && ~contains(lowAfter,"robust across seeds"),"No robustness overclaim.");
    checks{end+1,1} = check_row("SORD-20","No final CO2 claim",~contains(lowAfter,"final co2 reduction") && ~contains(lowAfter,"final emission reduction") && ~contains(lowAfter,"definitive emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("SORD-21","No final cost claim",~contains(lowAfter,"final cost reduction") && ~contains(lowAfter,"final economic saving") && ~contains(lowAfter,"definitive economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("SORD-22","No GA executed",true,"Text reordering only.");
    checks{end+1,1} = check_row("SORD-23","No model executed",true,"Text reordering only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,patchChecks);

    if all(Tchecks.pass)
        diagnosis = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_PASS";
        decision = "RERUN_MASTER_AFTER_CONCLUSIONS_AUDIT";
        next_step = "Re-run audit_master_after_conclusions_v96z.";
    else
        diagnosis = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(patchReport,'w');
    if fid < 0
        error('Could not open patch report: %s',patchReport);
    end

    fprintf(fid,'# PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Patch action\n\n`%s`\n\n',patchAction);
    fprintf(fid,'## Location evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Checks: `%s`\n',patchChecks);
    fprintf(fid,'- Headings diagnostic report: `%s`\n\n',headingsReport);
    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n',string(Tchecks.id(i)),string(Tchecks.check(i)),Tchecks.pass(i),string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','lockedSection7','backupFile','patchReport','patchChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','patchAction','locationEvidence','discSpan','limSpan','concSpan');

    out = struct();
    out.status = "PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.patchAction = patchAction;
    out.locationEvidence = locationEvidence;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.patchReport = patchReport;
    out.patchChecks = patchChecks;
    out.headingsReport = headingsReport;
    out.traceMat = traceMat;
    out.Tchecks = Tchecks;

    disp('=== PATCH MASTER SECTION ORDER DISCUSSION LIMITATIONS CONCLUSIONS v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== ACTION ===')
    disp(out.patchAction)
    disp('=== LOCATION EVIDENCE ===')
    disp(out.locationEvidence)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.backupFile)
    disp(out.patchReport)
    disp(out.headingsReport)
end

function [span, block] = get_section_span(txt,sectionName)
    pattern = "(?m)^#{1,6}\s*" + sectionName + "\s*$";
    starts = regexp(txt,pattern,'start');
    if isempty(starts)
        span = [NaN NaN];
        block = "";
        return
    end
    s = starts(1);
    rest = txt(s+1:end);
    nextRel = regexp(rest,'(?m)^#{1,6}\s+.*$','start','once');
    if isempty(nextRel)
        e = length(txt);
    else
        e = s + nextRel - 1;
    end
    span = [s e];
    block = txt(s:e);
end

function tf = section_order_ok(txt)
    idxRes = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','start');
    idxDisc = regexp(txt,'(?m)^#{1,6}\s*Discussion\s*$','start');
    idxLim = regexp(txt,'(?m)^#{1,6}\s*Limitations\s*$','start');
    idxConc = regexp(txt,'(?m)^#{1,6}\s*Conclusions\s*$','start');
    idxRef = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start');
    tf = true;
    if ~isempty(idxRes) && ~isempty(idxDisc), tf = tf && idxRes(1) < idxDisc(1); end
    if ~isempty(idxDisc) && ~isempty(idxLim), tf = tf && idxDisc(1) < idxLim(1); end
    if ~isempty(idxLim) && ~isempty(idxConc), tf = tf && idxLim(1) < idxConc(1); end
    if ~isempty(idxConc) && ~isempty(idxRef), tf = tf && idxConc(1) < idxRef(1); end
end

function s7 = extract_section7_flexible(txt)
    idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once');
    if isempty(idxStart)
        s7 = '';
        return
    end
    rest = txt(idxStart+1:end);
    idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Limitations\b|Conclusions\b|Conclusion\b|Conclusiones\b|References\b|Referencias\b).*$','once');
    if isempty(idxNext)
        s7 = txt(idxStart:end);
    else
        idxEnd = idxStart + idxNext - 1;
        s7 = txt(idxStart:idxEnd);
    end
end

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0, error('Could not write headings report: %s',filename); end
    fprintf(fid,'MASTER headings detected before section-order patch\n\n');
    if isempty(matches)
        fprintf(fid,'No Markdown headings detected.\n');
    else
        for i = 1:numel(matches)
            fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
        end
    end
    fclose(fid);
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
