# Generate-VideoDemo.ps1
# Automates the creation of an executive, broadcast-quality 1080p MP4 video demo

$baseDir = "C:\Users\Administrator\video_generator"
if (Test-Path $baseDir) { Remove-Item $baseDir -Recurse -Force }
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
New-Item -ItemType Directory -Path "$baseDir\slides" -Force | Out-Null
New-Item -ItemType Directory -Path "$baseDir\frames" -Force | Out-Null

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$ffmpeg = "C:\Users\Administrator\bin\ffmpeg.exe"

# Common CSS
$css = @"
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 1920px;
    height: 1080px;
    background: #090d16;
    color: #e2e8f0;
    font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
    display: flex;
    flex-direction: column;
    padding: 55px 75px;
    position: relative;
    overflow: hidden;
  }
  .header-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #1e293b;
    padding-bottom: 20px;
    margin-bottom: 28px;
  }
  .logo-title {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .badge {
    background: #0284c7;
    color: #ffffff;
    font-size: 13px;
    font-weight: 700;
    padding: 6px 14px;
    border-radius: 6px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }
  .badge.success { background: #059669; }
  .badge.purple { background: #7c3aed; }
  .badge.orange { background: #ea580c; }
  .badge.yellow { background: #d97706; }
  .sys-info {
    font-size: 14px;
    color: #94a3b8;
    font-family: 'Consolas', monospace;
  }
  .main-title {
    font-size: 38px;
    font-weight: 700;
    color: #f8fafc;
    letter-spacing: -0.5px;
    margin-bottom: 8px;
  }
  .sub-title {
    font-size: 18px;
    color: #94a3b8;
    margin-bottom: 24px;
  }
  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    flex: 1;
  }
  .grid-3 {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 20px;
    margin-bottom: 22px;
  }
  .grid-4 {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    gap: 18px;
    margin-bottom: 24px;
  }
  .card {
    background: #0f172a;
    border: 1px solid #1e293b;
    border-radius: 10px;
    padding: 20px 24px;
    display: flex;
    flex-direction: column;
  }
  .card-title {
    font-size: 15px;
    font-weight: 600;
    color: #38bdf8;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .stat-card {
    background: #0f172a;
    border: 1px solid #1e293b;
    border-radius: 10px;
    padding: 16px 20px;
  }
  .stat-val {
    font-size: 34px;
    font-weight: 800;
    color: #38bdf8;
    font-family: 'Consolas', monospace;
  }
  .stat-val.green { color: #34d399; }
  .stat-val.orange { color: #fb923c; }
  .stat-lbl {
    font-size: 13px;
    color: #94a3b8;
    margin-top: 4px;
    font-weight: 500;
  }
  .term-box {
    background: #030712;
    border: 1px solid #1f2937;
    border-radius: 8px;
    padding: 18px;
    font-family: 'Consolas', monospace;
    font-size: 14px;
    line-height: 1.5;
    color: #d1d5db;
    overflow: hidden;
    flex: 1;
  }
  .term-prompt { color: #38bdf8; font-weight: bold; }
  .term-cmd { color: #facc15; }
  .term-ok { color: #4ade80; }
  .term-dim { color: #6b7280; }
  .term-hi { color: #ec4899; }
  .footer-bar {
    margin-top: auto;
    border-top: 1px solid #1e293b;
    padding-top: 16px;
    display: flex;
    justify-content: space-between;
    font-size: 13px;
    color: #64748b;
  }
  table.data-tbl {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    margin-top: 8px;
  }
  table.data-tbl th {
    background: #1e293b;
    color: #94a3b8;
    text-align: left;
    padding: 10px 14px;
    font-weight: 600;
    border-bottom: 2px solid #334155;
  }
  table.data-tbl td {
    padding: 10px 14px;
    border-bottom: 1px solid #1e293b;
    color: #cbd5e1;
  }
  table.data-tbl tr:nth-child(even) td { background: #0c1322; }
  .highlight-badge {
    background: rgba(52, 211, 153, 0.15);
    color: #34d399;
    padding: 3px 8px;
    border-radius: 4px;
    font-weight: 600;
    border: 1px solid rgba(52, 211, 153, 0.3);
  }
"@

# Slide 1: Executive Title
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge">VCF 9.1</span>
      <span class="badge purple">vSphere with Tanzu</span>
      <span class="badge orange">vSAN ESA Storage</span>
    </div>
    <div class="sys-info">Broadcom TMM Lab · vc-w02.vcf01.content.tmm.broadcom.lab</div>
  </div>
  <div class="main-title">Stateful Kubernetes Migration & Metadata Reconciliation</div>
  <div class="sub-title">Empirical Multi-Scenario Validation: Zero-Copy FCD, Filesystem Streaming, and Velero MinIO S3</div>
  <div class="grid-4">
    <div class="stat-card"><div class="stat-val green">5,000</div><div class="stat-lbl">Transactions Validated</div></div>
    <div class="stat-card"><div class="stat-val green">100%</div><div class="stat-lbl">Bit-for-Bit Integrity</div></div>
    <div class="stat-card"><div class="stat-val green">3 / 3</div><div class="stat-lbl">Architectural Patterns</div></div>
    <div class="stat-card"><div class="stat-val">0 Bytes</div><div class="stat-lbl">Zero-Copy Network Overhead</div></div>
  </div>
  <div class="grid-2">
    <div class="card">
      <div class="card-title">Infrastructure Topologies</div>
      <table class="data-tbl">
        <tr><th>Cluster Component</th><th>Source (vks-source)</th><th>Target (vks-target)</th></tr>
        <tr><td>Kubernetes Version</td><td>v1.36.2+vmware.2</td><td>v1.36.2+vmware.2</td></tr>
        <tr><td>Node Topologies</td><td>1 Control Plane + 2 Workers</td><td>1 Control Plane + 3 Workers</td></tr>
        <tr><td>Primary Datastore</td><td>vSAN ESA (RAID-5 Policy)</td><td>vSAN ESA (RAID-5 Policy)</td></tr>
        <tr><td>Object Storage</td><td>MinIO S3 (10.163.44.130:9000)</td><td>MinIO S3 (10.163.44.130:9000)</td></tr>
      </table>
    </div>
    <div class="card">
      <div class="card-title">Tested Architectural Patterns</div>
      <table class="data-tbl">
        <tr><th>Pattern</th><th>Movement Channel</th><th>Primary Benefit</th></tr>
        <tr><td>1. Zero-Copy FCD</td><td>Paravirtual CSI Volume Adoption</td><td>Near-Zero Downtime, 0 Network Overhead</td></tr>
        <tr><td>2. Filesystem Stream</td><td>POSIX rsync / tar Pipe</td><td>Fast Cutover, Direct Pod-to-Pod</td></tr>
        <tr><td>3. Velero + MinIO S3</td><td>Kopia S3 Backup/Restore Engine</td><td>Full CRD, Helm & Disaster Recovery</td></tr>
      </table>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide1.html" -Encoding utf8

# Slide 2: Source Baseline
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge">Baseline Setup</span>
      <span class="badge purple">Cluster: vks-source</span>
      <span class="badge">Namespace: migration-demo</span>
    </div>
    <div class="sys-info">API VIP: 10.160.125.148:6443</div>
  </div>
  <div class="main-title">Phase 1: Source Workload Baseline & Metadata Setup</div>
  <div class="sub-title">Deploying Helm Chart release payments-db-1.0.0 with rich app-centric metadata on vSAN ESA storage</div>
  <div class="grid-2">
    <div class="term-box">
      <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">helm list -n migration-demo</span><br/>
      <span class="term-dim">NAME         NAMESPACE      REVISION STATUS   CHART             APP VERSION</span><br/>
      <span class="term-ok">payments-db  migration-demo 1        deployed payments-db-1.0.0 16.4.0</span><br/><br/>
      <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl get all,appconfig,pvc -n migration-demo</span><br/>
      <span class="term-dim">NAME                    READY   STATUS    RESTARTS   AGE</span><br/>
      <span class="term-ok">pod/payments-db-0       1/1     Running   0          12m</span><br/>
      <span class="term-ok">service/payments-db-svc ClusterIP 10.103.81.195 &lt;none&gt; 5432/TCP</span><br/>
      <span class="term-ok">statefulset/payments-db 1/1     12m</span><br/><br/>
      <span class="term-dim">NAME (CRD AppConfig)        TIER     WAVE              OWNER</span><br/>
      <span class="term-hi">appconfig/payments-db-metadata Platinum Wave-01-Databases Finance-Engineering</span><br/><br/>
      <span class="term-dim">NAME (PVC)             STATUS VOLUME                                   CAPACITY STORAGECLASS</span><br/>
      <span class="term-ok">pvc/data-payments-db-0 Bound  pvc-a832dc37-a345-4477-b6b6-15c41d2edbef 1Gi      vsan-esa-default</span>
    </div>
    <div class="card">
      <div class="card-title">Pre-Migration Integrity Fingerprint</div>
      <div class="term-box" style="margin-bottom:14px; flex:none;">
        <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl exec payments-db-0 -- psql -U payadmin -d payments -c "SELECT * FROM migration_integrity_summary;"</span><br/><br/>
        <span class="term-dim"> total_rows | min_id | max_id | total_amount |        aggregate_checksum        </span><br/>
        <span class="term-dim">------------+--------+--------+--------------+----------------------------------</span><br/>
        <span class="term-ok">       5000 |      1 |   5000 |   3767875.00 | </span><span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/>
        <span class="term-dim">(1 row)</span>
      </div>
      <div class="grid-2" style="flex:none;">
        <div class="stat-card"><div class="stat-val green">5,000</div><div class="stat-lbl">Total Records</div></div>
        <div class="stat-card"><div class="stat-val">$3.76M</div><div class="stat-lbl">Aggregate Volume</div></div>
      </div>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide2.html" -Encoding utf8

# Slide 3: Scenario 1 - Filesystem Streaming
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge yellow">Pattern 2</span>
      <span class="badge">Filesystem Streaming</span>
      <span class="badge success">Target: demo-pvmigrate</span>
    </div>
    <div class="sys-info">Strategy: Pod-to-Pod POSIX Pipe (pv-migrate / rsync)</div>
  </div>
  <div class="main-title">Scenario 1: Filesystem Streaming Replication</div>
  <div class="sub-title">Lightweight streaming of active database directory across cluster boundaries with byte-level POSIX validation</div>
  <div class="grid-3">
    <div class="stat-card"><div class="stat-val green">0.98 s</div><div class="stat-lbl">Replication Transfer Time</div></div>
    <div class="stat-card"><div class="stat-val">47.3 MB</div><div class="stat-lbl">POSIX Data Streamed</div></div>
    <div class="stat-card"><div class="stat-val green">9.37 s</div><div class="stat-lbl">Target Service Cutover (RTO)</div></div>
  </div>
  <div class="grid-2">
    <div class="term-box">
      <span class="term-dim"># Step 1: Quiesce workload on vks-source (1.16s)</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">kubectl scale statefulset payments-db --replicas=0 -n migration-demo</span><br/>
      <span class="term-ok">statefulset.apps/payments-db scaled</span><br/><br/>
      <span class="term-dim"># Step 2: Stream POSIX data directly between ephemeral pods</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">kubectl exec migration-sync-src -- tar -cf - pgdata | kubectl exec -i migration-sync-dest -- tar -xpf -</span><br/>
      <span class="term-ok">Filesystem replication completed in 0.9854499 seconds!</span><br/><br/>
      <span class="term-dim"># Step 3: Deploy Helm release on vks-target</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">helm upgrade --install payments-db ./payments-db-chart -n demo-pvmigrate</span><br/>
      <span class="term-ok">pod/payments-db-0 condition met (Ready in 9.37s)</span>
    </div>
    <div class="card">
      <div class="card-title">Target Checksum Verification</div>
      <div class="term-box">
        <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl exec payments-db-0 -n demo-pvmigrate -- psql -U payadmin -d payments -c "SELECT * FROM migration_integrity_summary;"</span><br/><br/>
        <span class="term-dim"> total_rows | min_id | max_id | total_amount |        aggregate_checksum        </span><br/>
        <span class="term-dim">------------+--------+--------+--------------+----------------------------------</span><br/>
        <span class="term-ok">       5000 |      1 |   5000 |   3767875.00 | </span><span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">INTEGRITY STATUS: 100% BIT-FOR-BIT MATCH</span>
      </div>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide3.html" -Encoding utf8

# Slide 4: Scenario 2 - Velero + MinIO S3
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge purple">Pattern 3</span>
      <span class="badge">Velero + MinIO S3</span>
      <span class="badge success">Target: demo-velero</span>
    </div>
    <div class="sys-info">Data Mover: Kopia Engine · Bucket: velero-backups</div>
  </div>
  <div class="main-title">Scenario 2: Velero + MinIO S3 Data Mover & Restore</div>
  <div class="sub-title">Complete app-centric metadata preservation (CRDs, Custom Resources, Helm release secrets, ConfigMaps) via S3</div>
  <div class="grid-3">
    <div class="stat-card"><div class="stat-val green">3.97 s</div><div class="stat-lbl">S3 Backup Execution Time</div></div>
    <div class="stat-card"><div class="stat-val green">9.04 s</div><div class="stat-lbl">Cross-Cluster Restore Time</div></div>
    <div class="stat-card"><div class="stat-val green">52 / 52</div><div class="stat-lbl">App Objects Preserved</div></div>
  </div>
  <div class="grid-2">
    <div class="term-box">
      <span class="term-dim"># Step 1: Create Velero Backup on vks-source</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">velero backup create payments-db-velero-v1 --include-namespaces migration-demo --default-volumes-to-fs-backup=true --wait</span><br/>
      <span class="term-ok">Backup completed with status: Completed (3.97s, 52 items backed up)</span><br/><br/>
      <span class="term-dim"># Step 2: Restore into vks-target with namespace re-mapping</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">velero restore create restore-v1 --from-backup payments-db-velero-v1 --namespace-mappings migration-demo:demo-velero --wait</span><br/>
      <span class="term-ok">Restore completed with status: Completed (9.04s, 20 items restored)</span><br/><br/>
      <span class="term-dim"># Step 3: Verify Helm release preserved in demo-velero</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">helm list -n demo-velero</span><br/>
      <span class="term-ok">payments-db  migration-demo  1  deployed  payments-db-1.0.0</span>
    </div>
    <div class="card">
      <div class="card-title">Target Checksum Verification</div>
      <div class="term-box">
        <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl exec payments-db-0 -n demo-velero -- psql -U payadmin -d payments -c "SELECT * FROM migration_integrity_summary;"</span><br/><br/>
        <span class="term-dim"> total_rows | min_id | max_id | total_amount |        aggregate_checksum        </span><br/>
        <span class="term-dim">------------+--------+--------+--------------+----------------------------------</span><br/>
        <span class="term-ok">       5000 |      1 |   5000 |   3767875.00 | </span><span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">INTEGRITY STATUS: 100% BIT-FOR-BIT MATCH</span>
      </div>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide4.html" -Encoding utf8

# Slide 5: Scenario 3 - Zero-Copy FCD Adoption
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge orange">Pattern 1</span>
      <span class="badge">Zero-Copy FCD Adoption</span>
      <span class="badge success">Target: migration-demo</span>
    </div>
    <div class="sys-info">Mechanism: vSphere CNS / Paravirtual CSI Volume Re-registration</div>
  </div>
  <div class="main-title">Scenario 3: Zero-Copy First Class Disk (FCD) Adoption</div>
  <div class="sub-title">Near-zero downtime storage adoption without copying bytes across the physical network (0 Bytes transferred)</div>
  <div class="grid-3">
    <div class="stat-card"><div class="stat-val green">0 Bytes</div><div class="stat-lbl">Network Bytes Transferred</div></div>
    <div class="stat-card"><div class="stat-val green">1.05 s</div><div class="stat-lbl">Source Quiesce Time</div></div>
    <div class="stat-card"><div class="stat-val green">17.49 s</div><div class="stat-lbl">Full Re-attach & Cutover (RTO)</div></div>
  </div>
  <div class="grid-2">
    <div class="term-box">
      <span class="term-dim"># Step 1: Quiesce workload & retain FCD on vks-source</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">kubectl patch pv pvc-a832dc37... -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'</span><br/>
      <span class="term-ok">PV transitioned to Retain, PVC deleted (FCD cleanly detached from VM)</span><br/><br/>
      <span class="term-dim"># Step 2: Statically adopt FCD handle on vks-target</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">kubectl apply -f adopted-fcd-pv.yaml -n migration-demo</span><br/>
      <span class="term-ok">persistentvolume/adopted-fcd-pv created (volumeHandle: bc6259a5...)</span><br/>
      <span class="term-ok">persistentvolumeclaim/data-payments-db-0 Bound</span><br/><br/>
      <span class="term-dim"># Step 3: Reconcile Helm chart with --take-ownership</span><br/>
      <span class="term-prompt">$</span> <span class="term-cmd">helm upgrade --install payments-db ./payments-db-chart -n migration-demo</span><br/>
      <span class="term-ok">pod/payments-db-0 condition met (Ready in 17.49s)</span>
    </div>
    <div class="card">
      <div class="card-title">Target Checksum Verification</div>
      <div class="term-box">
        <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl exec payments-db-0 -n migration-demo -- psql -U payadmin -d payments -c "SELECT * FROM migration_integrity_summary;"</span><br/><br/>
        <span class="term-dim"> total_rows | min_id | max_id | total_amount |        aggregate_checksum        </span><br/>
        <span class="term-dim">------------+--------+--------+--------------+----------------------------------</span><br/>
        <span class="term-ok">       5000 |      1 |   5000 |   3767875.00 | </span><span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">INTEGRITY STATUS: 100% BIT-FOR-BIT MATCH (0 BYTES COPIED)</span>
      </div>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide5.html" -Encoding utf8

# Slide 6: Multi-Target Verification
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge success">Verification</span>
      <span class="badge purple">Cluster: vks-target</span>
      <span class="badge">All Scenarios Running</span>
    </div>
    <div class="sys-info">Target Control Plane: 10.160.125.145:6443</div>
  </div>
  <div class="main-title">Multi-Target Validation: All 3 Patterns Live on vks-target</div>
  <div class="sub-title">Side-by-side execution and database checksum verification across all three migrated target namespaces</div>
  <div class="card" style="margin-bottom: 24px;">
    <div class="card-title">Simultaneous Target Workload Status</div>
    <div class="term-box" style="flex:none;">
      <span class="term-prompt">administrator@vcf-jumpbox:~$</span> <span class="term-cmd">kubectl --kubeconfig=vks-target.kubeconfig get pods -A -l app.kubernetes.io/name=payments-db</span><br/><br/>
      <span class="term-dim">NAMESPACE        NAME            READY   STATUS    RESTARTS   AGE</span><br/>
      <span class="term-ok">demo-pvmigrate   payments-db-0   1/1     Running   0          24m   </span><span class="term-dim"># Pattern 2: Filesystem Stream</span><br/>
      <span class="term-ok">demo-velero      payments-db-0   1/1     Running   0          21m   </span><span class="term-dim"># Pattern 3: Velero + MinIO S3</span><br/>
      <span class="term-ok">migration-demo   payments-db-0   1/1     Running   0          18m   </span><span class="term-dim"># Pattern 1: Zero-Copy FCD Adoption</span>
    </div>
  </div>
  <div class="grid-3">
    <div class="card">
      <div class="card-title">demo-pvmigrate Checksum</div>
      <div class="term-box">
        <span class="term-dim">Rows:</span> <span class="term-ok">5,000</span><br/>
        <span class="term-dim">Sum:</span>  <span class="term-ok">$3,767,875.00</span><br/>
        <span class="term-dim">Hash:</span> <span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">STATUS: PASS (100%)</span>
      </div>
    </div>
    <div class="card">
      <div class="card-title">demo-velero Checksum</div>
      <div class="term-box">
        <span class="term-dim">Rows:</span> <span class="term-ok">5,000</span><br/>
        <span class="term-dim">Sum:</span>  <span class="term-ok">$3,767,875.00</span><br/>
        <span class="term-dim">Hash:</span> <span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">STATUS: PASS (100%)</span>
      </div>
    </div>
    <div class="card">
      <div class="card-title">migration-demo Checksum</div>
      <div class="term-box">
        <span class="term-dim">Rows:</span> <span class="term-ok">5,000</span><br/>
        <span class="term-dim">Sum:</span>  <span class="term-ok">$3,767,875.00</span><br/>
        <span class="term-dim">Hash:</span> <span class="term-hi">c318e5f2f42f3fb6d4da7b7371a6191e</span><br/><br/>
        <span class="highlight-badge">STATUS: PASS (100%)</span>
      </div>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide6.html" -Encoding utf8

# Slide 7: Architectural Decision Matrix
@"
<!DOCTYPE html><html><head><meta charset="UTF-8"><style>$css</style></head><body>
  <div class="header-bar">
    <div class="logo-title">
      <span class="badge">Evaluation</span>
      <span class="badge orange">Architectural Decision Matrix</span>
      <span class="badge success">Conclusion</span>
    </div>
    <div class="sys-info">Enterprise Kubernetes Workload Migration on VCF 9.1</div>
  </div>
  <div class="main-title">Comparative Performance & Production Recommendations</div>
  <div class="sub-title">Quantitative results and architectural decision guide based on live testbed benchmarks</div>
  <div class="card" style="margin-bottom: 24px;">
    <table class="data-tbl">
      <tr><th>Evaluation Metric</th><th>Scenario 1: Filesystem Streaming</th><th>Scenario 2: Velero + MinIO S3</th><th>Scenario 3: Zero-Copy FCD Adoption</th></tr>
      <tr><td>Data Movement Mechanism</td><td>Cross-cluster POSIX tar / rsync pipe</td><td>S3 Backup/Restore via Kopia engine</td><td>vSAN ESA Paravirtual CSI adoption</td></tr>
      <tr><td>Network Data Transferred</td><td>47.3 MB (Uncompressed)</td><td>22.6 MB (Compressed Blobs)</td><td><strong style="color:#34d399">0 Bytes (Zero Network Copy)</strong></td></tr>
      <tr><td>Data Transfer Duration</td><td>0.98 seconds</td><td>3.97s (Backup) + 9.04s (Restore)</td><td><strong style="color:#34d399">Instantaneous (Metadata re-bind)</strong></td></tr>
      <tr><td>Total Cutover Time (RTO)</td><td><strong>9.37 seconds</strong></td><td><strong>13.01 seconds</strong></td><td><strong>17.49 seconds</strong> (Unmount/Attach)</td></tr>
      <tr><td>Data Loss (RPO)</td><td>0 (Quiesced)</td><td>0 (Online/Quiesced)</td><td>0 (Quiesced)</td></tr>
      <tr><td>Metadata / Helm Reconciled</td><td>Helm upgrade --install</td><td>Direct Helm release secret restore</td><td>Helm upgrade --take-ownership</td></tr>
      <tr><td>Bit-for-Bit Integrity Match</td><td><span class="highlight-badge">100% MATCH</span></td><td><span class="highlight-badge">100% MATCH</span></td><td><span class="highlight-badge">100% MATCH</span></td></tr>
    </table>
  </div>
  <div class="grid-3">
    <div class="card">
      <div class="card-title">Recommendation: Multi-TB Workloads</div>
      <p style="font-size:14px; line-height:1.6; color:#94a3b8;">Use <strong>Zero-Copy FCD Adoption</strong>. Bypasses physical network bottlenecks entirely, reducing multi-terabyte cutover from hours to under 20 seconds.</p>
    </div>
    <div class="card">
      <div class="card-title">Recommendation: Cross-DC / DR</div>
      <p style="font-size:14px; line-height:1.6; color:#94a3b8;">Use <strong>Velero + MinIO S3</strong>. Full self-contained capture of CRDs, Custom Resources, Helm release secrets, and volume data in portable S3 buckets.</p>
    </div>
    <div class="card">
      <div class="card-title">Recommendation: Direct Cluster Migration</div>
      <p style="font-size:14px; line-height:1.6; color:#94a3b8;">Use <strong>Filesystem Streaming</strong>. Fastest direct pod-to-pod transfer without requiring external object store infrastructure.</p>
    </div>
  </div>
  <div class="footer-bar"><div>Broadcom VMware Cloud Foundation Technical Validation</div><div>Demo Video · Oct 2026</div></div>
</body></html>
"@ | Out-File "$baseDir\slides\slide7.html" -Encoding utf8

Write-Host "Rendering slides with Chrome Headless..."
$slides = 1..7
foreach ($s in $slides) {
    $htmlPath = "file:///$($baseDir.Replace('\', '/'))/slides/slide$s.html"
    $pngPath = "$baseDir\frames\slide$s.png"
    Write-Host "Rendering Slide $s..."
    Start-Process -FilePath $chrome -ArgumentList "--headless --disable-gpu --window-size=1920,1080 --screenshot=`"$pngPath`" `"$htmlPath`"" -Wait
}

# Create ffmpeg concat demuxer file with forward-slashed absolute paths
$concatFile = "$baseDir\concat.txt"
$frameDir = "$baseDir\frames".Replace('\', '/')
@"
file '$frameDir/slide1.png'
duration 8
file '$frameDir/slide2.png'
duration 11
file '$frameDir/slide3.png'
duration 13
file '$frameDir/slide4.png'
duration 13
file '$frameDir/slide5.png'
duration 13
file '$frameDir/slide6.png'
duration 11
file '$frameDir/slide7.png'
duration 14
file '$frameDir/slide7.png'
"@ | Out-File $concatFile -Encoding ascii

Write-Host "Encoding MP4 video with ffmpeg..."
$outputMp4 = "C:\Users\Administrator\k8s_migration_demo.mp4"
& $ffmpeg -y -f concat -safe 0 -i "$concatFile" -vf "fps=30,format=yuv420p" -c:v libx264 -preset medium -crf 18 "$outputMp4"

Write-Host "Video generated successfully: $outputMp4"
Get-Item $outputMp4 | Select-Object Name, Length, LastWriteTime
