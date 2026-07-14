%% patch_master_preliminary_review_repairs_v96z.m
% 9.6z-repair-a | MASTER-PRELIMINARY-REVIEW-REPAIRS-v96z-001
% Repairs after preliminary review:
% 1) Remove duplicate modular skeleton subsections in 3.1--3.5, 5.1--5.4, 6.1--6.4.
% 2) Rebuild #5 Mathematical model with equations and traceability.
% 3) Add GA search-budget limitation to #8.
% 4) Add 31--45% hybrid-vs-gas-LPG energy-reduction result to Abstract and Conclusions.
% 5) Reduce repeated "computed nondominated set" wording in Results and Conclusions.
%
% WRITE_WITH_BACKUP_AND_STOP_GUARDS. Text only. No GA/model execution.

clear; clc;
fprintf('\n=== MASTER PRELIMINARY REVIEW REPAIRS v96z ===\n');

rootDir='C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';
masterPath=fullfile(rootDir,'06_manuscript','article_Q1','draft_sections','MASTER_manuscript_v01.md');
draftDir=fullfile(rootDir,'06_manuscript','article_Q1','draft_sections');
reviewDir=fullfile(rootDir,'06_manuscript','article_Q1','review');
if ~exist(reviewDir,'dir'), mkdir(reviewDir); end
ts=datestr(now,'yyyymmdd_HHMMSS');
backupPath=fullfile(draftDir,sprintf('MASTER_manuscript_v01_BEFORE_PRELIMINARY_REVIEW_REPAIRS_v96z_%s.md',ts));
reportPath=fullfile(reviewDir,'MASTER_PRELIMINARY_REVIEW_REPAIRS_v96z_report.md');
checksPath=fullfile(reviewDir,'MASTER_PRELIMINARY_REVIEW_REPAIRS_v96z_Tchecks.csv');
headingsPath=fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_preliminary_review_repairs_after.txt');

T=table(string.empty,string.empty,logical.empty,string.empty,'VariableNames',{'id','check','pass','evidence'});
T=add(T,'PRE-01','MASTER exists',exist(masterPath,'file')==2,masterPath);
if exist(masterPath,'file')~=2, stop(T,reportPath,checksPath,headingsPath,masterPath,backupPath,'MASTER_PRELIMINARY_REVIEW_REPAIRS_REVIEW_REQUIRED','STOP_MASTER_NOT_FOUND','MASTER not found'); end
txt=normNL(fileread(masterPath));
T=add(T,'PRE-02','MASTER readable',strlength(string(txt))>0,sprintf('chars=%d',strlength(string(txt))));
H=headings(txt);
T=add(T,'PRE-03','Route-B order valid before repairs',routeOK(H),routeEv(H));
need=["# 1. Abstract","# 3. Introduction","# 5. Mathematical model","# 6. Optimization methodology","# 7. Results and discussion","# 8. Limitations","# 9. Conclusions","# 10. Nomenclature","# 11. References","# 12. Supplementary material"];
miss=strings(0,1);
for k=1:numel(need), if isempty(hidx(H,need(k))), miss(end+1,1)=need(k); end, end %#ok<AGROW>
T=add(T,'PRE-04','Required sections detected',isempty(miss),pick(isempty(miss),'all detected',strjoin(miss,' | ')));
if any(~T.pass)
    stop(T,reportPath,checksPath,headingsPath,masterPath,backupPath,'MASTER_PRELIMINARY_REVIEW_REPAIRS_REVIEW_REQUIRED','STOP_STRUCTURAL_PRECHECK_FAILED','Structural precheck failed');
end

work=txt;

% 1. Remove duplicate modular subsections.
[work,removed,ev]=removeDupSubsections(work);
T=add(T,'DRAFT-01','Duplicate target subsections removed if present',true,sprintf('removed=%d | %s',removed,ev));

% 2. Rebuild #5.
H=headings(work);
modelBlock=buildModelBlock();
work=replaceSec(work,H,'# 5. Mathematical model',modelBlock);
H=headings(work);
m5=sec(work,H,'# 5. Mathematical model');
T=add(T,'DRAFT-02','#5 contains four-state equations',all([contains(string(m5),'dT_a'),contains(string(m5),'dT_p'),contains(string(m5),'dMR'),contains(string(m5),'dT_s')]),'dT_a/dT_p/dMR/dT_s');
T=add(T,'DRAFT-03','#5 contains decision-variable traceability',all([contains(string(m5),'m_dot'),contains(string(m5),'T_min'),contains(string(m5),'r_rec'),contains(string(m5),'t_rec_ini'),contains(string(m5),'Q_aux')]),'m_dot/T_min/r_rec/t_rec_ini/Q_aux');

% 3. Add GA search-budget limitation.
H=headings(work); lim=sec(work,H,'# 8. Limitations');
if ~contains(string(lim),'population size of 24')
    lim=[strtrim(lim) newline newline ...
    'Additional search-budget limitation. The formal R1 run used a single seed, `seed = 61001`, a population size of 24, and 50 generations. Together with `exitflag = 0`, this configuration should be interpreted as a finite computational search that reached the prescribed generation limit rather than a convergence-certified exploration of the full trade-off space. The reported candidates are therefore operationally useful members of the computed set under the specified settings, not evidence of exhaustive search convergence.' newline];
    work=replaceSec(work,H,'# 8. Limitations',lim);
end
H=headings(work); lim=sec(work,H,'# 8. Limitations');
T=add(T,'DRAFT-04','Limitations include GA search-budget limitation',contains(string(lim),'population size of 24')&&contains(string(lim),'50 generations')&&contains(string(lim),'exitflag = 0'),'pop=24/gen=50/exitflag=0');

% 4. Add 31--45% result to Abstract and Conclusions.
H=headings(work); ab=sec(work,H,'# 1. Abstract');
if ~contains(string(ab),'31--45%') && ~contains(string(ab),'31–45%')
    ab=[strtrim(ab) newline newline ...
    'Relative to the gas-LPG baseline, the hybrid operating modes reduced auxiliary-energy demand by approximately 31--45%, with the energy-conservative R1_solution_7 reaching the largest reduction while satisfying the terminal moisture-ratio criterion.' newline];
    work=replaceSec(work,H,'# 1. Abstract',ab);
end
H=headings(work); co=sec(work,H,'# 9. Conclusions');
if ~contains(string(co),'31--45%') && ~contains(string(co),'31–45%')
    co=[strtrim(co) newline newline ...
    'The strongest quantitative outcome of the comparison is the auxiliary-energy reduction achieved by hybrid operation: across the selected feasible cases, the hybrid configurations reduced auxiliary-energy demand by approximately 31--45% relative to the gas-LPG baseline. This range is the principal energy-performance result, while the individual candidates retain different trade-offs between final moisture ratio and energy demand.' newline];
    work=replaceSec(work,H,'# 9. Conclusions',co);
end
H=headings(work);
ab=sec(work,H,'# 1. Abstract'); co=sec(work,H,'# 9. Conclusions');
T=add(T,'DRAFT-05','Abstract includes 31--45% result',contains(string(ab),'31--45%')||contains(string(ab),'31–45%'),'31--45 in Abstract');
T=add(T,'DRAFT-06','Conclusions include 31--45% result',contains(string(co),'31--45%')||contains(string(co),'31–45%'),'31--45 in Conclusions');

% 5. Reduce repeated phrase in later sections only.
beforeCnt=countLit(work,'computed nondominated set');
H=headings(work);
for s=["# 7. Results and discussion","# 9. Conclusions"]
    sg=sec(work,H,s);
    sg2=reducePhrase(sg,'computed nondominated set','computed set',1);
    work=replaceSec(work,H,s,sg2);
    H=headings(work);
end
afterCnt=countLit(work,'computed nondominated set');
T=add(T,'DRAFT-07','Repeated computed nondominated set wording reduced',afterCnt<beforeCnt,sprintf('before=%d after=%d',beforeCnt,afterCnt));

% Postchecks.
H2=headings(work);
T=add(T,'POST-01','Route-B order valid after repairs',routeOK(H2),routeEv(H2));
[~,remain,ev2]=removeDupSubsections(work);
T=add(T,'POST-02','No duplicate target subsection headings remain',remain==0,sprintf('remaining=%d | %s',remain,ev2));
m5=sec(work,H2,'# 5. Mathematical model');
T=add(T,'POST-03','#5 is no longer bullet-only skeleton',countLit(m5,[newline '- '])<=12 && countLit(m5,'$$')>=2,sprintf('bullets=%d eqDelims=%d',countLit(m5,[newline '- ']),countLit(m5,'$$')));
T=add(T,'POST-04','No audit-trigger global Pareto wording introduced',countLit(work,'global Pareto front')==0 && countLit(work,'global Pareto-front')==0,'global Pareto wording absent');
T=add(T,'POST-05','No GA executed',true,'Text-only repair');
T=add(T,'POST-06','No drying model executed',true,'Text-only repair');

if any(~T.pass)
    stop(T,reportPath,checksPath,headingsPath,masterPath,backupPath,'MASTER_PRELIMINARY_REVIEW_REPAIRS_REVIEW_REQUIRED','STOP_REPAIR_CHECK_FAILED','Repair check failed');
end

copyfile(masterPath,backupPath);
T=add(T,'WRITE-01','Backup created',exist(backupPath,'file')==2,backupPath);
fid=fopen(masterPath,'w'); fprintf(fid,'%s',work); fclose(fid);
T=add(T,'WRITE-02','MASTER updated',true,masterPath);
writeHeadings(H2,headingsPath,masterPath);
diagnosis='MASTER_PRELIMINARY_REVIEW_REPAIRS_PASS';
decision='MASTER_UPDATED_WITH_PRELIMINARY_REVIEW_REPAIRS';
writeReport(T,reportPath,checksPath,headingsPath,masterPath,backupPath,diagnosis,decision,'Preliminary review repairs completed.');
fprintf('\nDiagnosis: %s\nDecision:  %s\nReport:    %s\nChecks:    %s\nHeadings:  %s\nBackup:    %s\n',diagnosis,decision,reportPath,checksPath,headingsPath,backupPath);
fprintf('\nMASTER_PRELIMINARY_REVIEW_REPAIRS_DONE\n');

%% Functions
function T=add(T,id,check,pass,evidence)
if isempty(pass), p=false; else, p=all(logical(pass(:))); end
if ischar(evidence), e=string(evidence); elseif isstring(evidence), e=strjoin(evidence(:).',' | '); else, e=string(evidence); end
T=[T; table(string(id),string(check),logical(p),string(e),'VariableNames',{'id','check','pass','evidence'})];
end
function t=normNL(t), t=strrep(t,char([13 10]),newline); t=strrep(t,char(13),newline); end
function s=pick(c,a,b), if c, s=a; else, s=b; end, end
function n=countLit(t,p), if isstring(t), t=char(t); end, if isstring(p), p=char(p); end, n=numel(strfind(t,p)); end
function H=headings(t)
t=normNL(t); L=splitlines(string(t)); n=numel(L); starts=zeros(n,1); pos=1;
for i=1:n, starts(i)=pos; pos=pos+strlength(L(i))+1; end
ln=[]; cp=[]; lv=[]; raw=strings(0,1); title=strings(0,1);
for i=1:n
    li=char(L(i)); tok=regexp(li,'^(#{1,6})\s+(.+?)\s*$','tokens','once');
    if ~isempty(tok)
        ln(end+1,1)=i; cp(end+1,1)=starts(i); lv(end+1,1)=numel(tok{1}); raw(end+1,1)=string(li); title(end+1,1)=string(strtrim(tok{2})); %#ok<AGROW>
    end
end
H=table(ln,cp,lv,raw,title,'VariableNames',{'line','charpos','level','raw','title'});
end
function ix=hidx(H,r), ix=find(strcmp(strtrim(H.raw),strtrim(string(r)))); end
function p=fchar(H,ix), if isempty(ix), p=NaN; else, p=H.charpos(ix(1)); end, end
function ok=routeOK(H)
pos=[fchar(H,hidx(H,'# 7. Results and discussion')),fchar(H,hidx(H,'## 7.5 Discussion')),fchar(H,hidx(H,'# 8. Limitations')),fchar(H,hidx(H,'# 9. Conclusions')),fchar(H,hidx(H,'# 10. Nomenclature')),fchar(H,hidx(H,'# 11. References')),fchar(H,hidx(H,'# 12. Supplementary material'))];
ok=all(~isnan(pos))&&all(diff(pos)>0);
end
function ev=routeEv(H)
pos=[fchar(H,hidx(H,'# 7. Results and discussion')),fchar(H,hidx(H,'## 7.5 Discussion')),fchar(H,hidx(H,'# 8. Limitations')),fchar(H,hidx(H,'# 9. Conclusions')),fchar(H,hidx(H,'# 10. Nomenclature')),fchar(H,hidx(H,'# 11. References')),fchar(H,hidx(H,'# 12. Supplementary material'))];
ev=sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g',pos);
end
function sg=sec(t,H,r)
ix=hidx(H,r); if isempty(ix), sg=''; return; end
i=ix(1); st=H.charpos(i); en=strlength(string(t))+1;
for j=i+1:height(H), if H.level(j)<=H.level(i), en=H.charpos(j); break; end, end
sg=char(extractBetween(string(t),st,en-1));
end
function out=replaceSec(t,H,r,nb)
ix=hidx(H,r); if isempty(ix), error('Heading not found: %s',r); end
i=ix(1); st=H.charpos(i); en=strlength(string(t))+1;
for j=i+1:height(H), if H.level(j)<=H.level(i), en=H.charpos(j); break; end, end
out=char(extractBefore(string(t),st)+string(nb)+newline+extractAfter(string(t),en-1));
end
function [out,removed,ev]=removeDupSubsections(t)
H=headings(t); keys=strings(height(H),1); target=false(height(H),1);
for i=1:height(H)
    tok=regexp(char(H.raw(i)),'^##\s+(3\.[1-5]|5\.[1-4]|6\.[1-4])\b','tokens','once');
    if ~isempty(tok), keys(i)=string(tok{1}); target(i)=true; end
end
starts=[]; ends=[]; labels=strings(0,1); uk=unique(keys(target));
for k=1:numel(uk)
    if strlength(uk(k))==0, continue; end
    ids=find(target & keys==uk(k));
    if numel(ids)>1
        for m=2:numel(ids)
            ii=ids(m); st=H.charpos(ii); en=strlength(string(t))+1;
            for j=ii+1:height(H), if H.level(j)<=H.level(ii), en=H.charpos(j); break; end, end
            starts(end+1,1)=st; ends(end+1,1)=en; labels(end+1,1)=H.raw(ii); %#ok<AGROW>
        end
    end
end
removed=numel(starts); ev=pick(removed==0,'none',strjoin(labels,' || ')); out=string(t);
[~,ord]=sort(starts,'descend');
for q=1:numel(ord), st=starts(ord(q)); en=ends(ord(q)); out=extractBefore(out,st)+extractAfter(out,en-1); end
out=char(out);
end
function b=buildModelBlock()
b=sprintf(['# 5. Mathematical model\n\n' ...
'`STATUS: DRAFT_READY_FOR_REVIEW`\n\n' ...
'The dryer is represented as a lumped dynamic system with four state variables: process-air temperature `T_a`, product temperature `T_p`, product moisture ratio `MR`, and an equivalent structural temperature `T_s`. The model is used as the simulation core for all operating policies evaluated by the optimization routine. Its purpose is not to resolve local spatial gradients inside the tunnel, but to retain the dominant thermal and drying couplings needed to compare feasible operating decisions under the same numerical assumptions.\n\n' ...
'## 5.1 State vector and decision-variable coupling\n\n' ...
'The state vector is\n\n$$\nx(t)=\\left[T_a(t),\\,T_p(t),\\,MR(t),\\,T_s(t)\\right]^T.\n$$\n\n' ...
'The operational decision vector used later in the optimization is\n\n$$\nu=\\left[\\dot{m},\\,T_{min},\\,r_{rec},\\,t_{rec,ini}\\right]^T.\n$$\n\n' ...
'Here, `m_dot` controls process-air mass flow rate, `T_min` defines the minimum admissible process-air temperature, `r_rec` defines the recirculated-air fraction after recirculation starts, and `t_rec_ini` defines the activation time of recirculation. These four variables affect the air-side energy balance, the auxiliary-energy requirement, and the drying trajectory used to compute terminal `MR`.\n\n' ...
'## 5.2 Air-side energy balance\n\n' ...
'The process-air temperature is modeled through a lumped energy balance:\n\n$$\nC_a\\frac{dT_a}{dt}=\\dot{Q}_{sol}(t)+\\dot{Q}_{aux}(t)-\\dot{m}c_{p,a}\\left[T_a(t)-T_{in}(t)\\right]-h_{ap}A_p\\left[T_a(t)-T_p(t)\\right]-h_{as}A_s\\left[T_a(t)-T_s(t)\\right].\n$$\n\n' ...
'`Q_sol` is the useful solar-air-heater contribution, `Q_aux` is the auxiliary LPG heat supplied when the hybrid controller cannot maintain the imposed temperature policy, and the final two terms represent heat exchange with the product and dryer structure. Recirculation modifies the effective inlet condition `T_in(t)` after `t_rec_ini`, with the mixing level controlled by `r_rec`. The auxiliary term is accumulated over time to obtain the reported `Q_aux` objective in kWh.\n\n' ...
'## 5.3 Product thermal and drying submodel\n\n' ...
'The product temperature follows a lumped balance:\n\n$$\nC_p\\frac{dT_p}{dt}=h_{ap}A_p\\left[T_a(t)-T_p(t)\\right]-\\dot{Q}_{evap}(t).\n$$\n\n' ...
'The moisture-ratio dynamics are represented as\n\n$$\n\\frac{dMR}{dt}=-k_d\\left(T_a,T_p,\\dot{m}\\right)MR(t),\n$$\n\n' ...
'where `k_d` is an effective drying coefficient evaluated from the operating condition. This links terminal `MR` directly to air temperature, product temperature, and flow-rate policy. The feasibility criterion used in the manuscript is terminal `MR <= 0.1`.\n\n' ...
'## 5.4 Structural thermal response and numerical integration\n\n' ...
'The equivalent dryer-structure temperature is represented by\n\n$$\nC_s\\frac{dT_s}{dt}=h_{as}A_s\\left[T_a(t)-T_s(t)\\right]-U_sA_s\\left[T_s(t)-T_{amb}(t)\\right].\n$$\n\n' ...
'The four coupled ordinary differential equations are integrated with the same time base used in the optimization evaluations. For each candidate decision vector, the model returns terminal moisture ratio, accumulated auxiliary-energy demand, and the derived conditional cost or emissions indicators used in post-processing. Economic and CO2-related outputs are downstream indicators; they do not alter the physical state equations.\n']);
end
function out=reducePhrase(s,phrase,repl,keep)
s=char(s); ix=strfind(s,phrase); if numel(ix)<=keep, out=s; return; end
for k=numel(ix):-1:(keep+1), st=ix(k); en=st+length(phrase)-1; s=[s(1:st-1) repl s(en+1:end)]; end
out=s;
end
function writeHeadings(H,p,master)
fid=fopen(p,'w'); fprintf(fid,'MASTER HEADINGS DETECTED - PRELIMINARY REVIEW REPAIRS AFTER\n\nMASTER: %s\n\n',master);
for i=1:height(H), fprintf(fid,'%04d | line %05d | char %08d | level %d | %s\n',i,H.line(i),H.charpos(i),H.level(i),H.raw(i)); end
fclose(fid);
end
function stop(T,report,checks,heads,master,backup,diag,dec,note)
writetable(T,checks); writeReport(T,report,checks,heads,master,backup,diag,dec,note);
fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n',diag,dec,note,report,checks);
fprintf('\nMASTER_PRELIMINARY_REVIEW_REPAIRS_STOPPED_WITH_NO_WRITE\n'); error('%s: %s',dec,note);
end
function writeReport(T,report,checks,heads,master,backup,diag,dec,note)
writetable(T,checks); fid=fopen(report,'w');
fprintf(fid,'# MASTER_PRELIMINARY_REVIEW_REPAIRS_v96z report\n\n## Identifier\n\n`MASTER-PRELIMINARY-REVIEW-REPAIRS-v96z-001`\n\n## Diagnosis\n\n`%s`\n\n## Decision\n\n`%s`\n\n## Note\n\n`%s`\n\n## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n',diag,dec,note);
fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings after: `%s`\n\n',master,backup,checks,heads);
F=T(~T.pass,:); fprintf(fid,'## Failed checks\n\n');
if isempty(F), fprintf(fid,'None.\n\n'); else, fprintf(fid,'| id | check | evidence |\n|---|---|---|\n'); for i=1:height(F), fprintf(fid,'| `%s` | %s | `%s` |\n',F.id(i),F.check(i),F.evidence(i)); end, fprintf(fid,'\n'); end
fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
for i=1:height(T), fprintf(fid,'| `%s` | %s | %d | `%s` |\n',T.id(i),T.check(i),T.pass(i),T.evidence(i)); end
fclose(fid);
end
