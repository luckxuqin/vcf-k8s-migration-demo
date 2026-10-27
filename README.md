# Enterprise Kubernetes Stateful Workload Migration & Metadata Reconciliation on VMware Cloud Foundation 9.1

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live%20Showcase-brightgreen?logo=github)](https://luckxuqin.github.io/vcf-k8s-migration-demo/)
[![VMware Cloud Foundation](https://img.shields.io/badge/VCF-9.1.0-blue?logo=vmware)](https://www.vmware.com/products/cloud-foundation.html)
[![vSphere with Tanzu](https://img.shields.io/badge/Tanzu-v1.36.2-purple?logo=kubernetes)](https://tanzu.vmware.com/)
[![vSAN ESA](https://img.shields.io/badge/vSAN-ESA%20NVMe-orange)](https://www.vmware.com/products/vsan.html)

This repository contains the complete empirical migration testbed, Helm charts, Kubernetes CRDs, automation scripts, and benchmark audits validating stateful Kubernetes workload migration patterns on **VMware Cloud Foundation (VCF) 9.1** and **vSAN ESA**.

---

## 🌐 Live GitHub Pages Showcase & Video Demo

👉 **Visit the Live Showcase:** [**https://luckxuqin.github.io/vcf-k8s-migration-demo/**](https://luckxuqin.github.io/vcf-k8s-migration-demo/)

- 🎥 **Full HD Video Demonstration**: Watch the 1080p recorded walkthrough with interactive chapter jumps.
- 📊 **Performance Matrix**: Compare RTO, RPO, and network transfer speeds side-by-side.
- 🔍 **Interactive Object Inventory**: Filter all 22 migrated Kubernetes resources.

---

## 🎯 Architectural Patterns Validated

| Scenario | Migration Architectural Pattern | Movement Mechanism | RTO (Cutover) | Network Bandwidth | Checksum Integrity |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Scenario 1** | **Filesystem Streaming Replication** | Ephemeral pod-to-pod POSIX pipe (`pv-migrate` / rsync) | **9.37 seconds** | ~47.3 MB | `c318e5f2f42f3fb6d4da7b7371a6191e` (100%) |
| **Scenario 2** | **Velero + MinIO S3 Data Mover** | Kopia pod volume engine + S3 bucket backup & restore | **13.01 seconds** | ~22.6 MB (Compressed) | `c318e5f2f42f3fb6d4da7b7371a6191e` (100%) |
| **Scenario 3** | **Zero-Copy First Class Disk (FCD) Adoption** | vSphere Paravirtual CSI Volume Re-registration | **17.49 seconds** | **0 Bytes (Zero network copy)** | `c318e5f2f42f3fb6d4da7b7371a6191e` (100%) |

---

## 🏗️ Infrastructure Topology

- **vCenter Server**: `vc-w02.vcf01.content.tmm.broadcom.lab` (vSphere 9.1.0, Build 25629530)
- **Workload Domain Cluster**: `lvn-vcf01-w02-cl01` (vSAN ESA NVMe-oF fabric, RAID-5 storage policy)
- **Source Cluster (`vks-source`)**: K8s `v1.36.2+vmware.2`, 1 Control Plane + 2 Workers (`172.26.0.0/24`)
- **Target Cluster (`vks-target`)**: K8s `v1.36.2+vmware.2`, 1 Control Plane + 3 Workers (`172.26.0.0/24`)
- **Object Storage**: MinIO S3 (`https://10.163.44.130:9000`)
- **Database Baseline**: PostgreSQL 16.4 Alpine, 5,000 transaction records totaling `$3,767,875.00`

---

## 📂 Repository Directory Layout

```text
vcf-k8s-migration-demo/
├── index.html                      # Interactive GitHub Pages single-page web app
├── README.md                       # Repository overview and technical documentation
├── docs/
│   └── MIGRATION_EXECUTION_RECORD.md # Full audit log, execution traces, and benchmarks
├── helm/
│   ├── payments-db-chart/          # Enterprise Helm v3 chart with CRDs and templates
│   └── helm-artifacts/             # Packaged payments-db-1.0.0.tgz archive
├── manifests/
│   ├── adopted-fcd-pv.yaml         # Zero-Copy static PV/PVC adoption manifest
│   ├── migration-sync-src.yaml     # Ephemeral POSIX stream reader pod
│   ├── migration-sync-dest.yaml    # Ephemeral POSIX stream writer pod
│   ├── pvmigrate-target-pvc.yaml   # Target PVC manifest for streaming sync
│   ├── velero-install.yaml         # Complete Velero CRD and deployment bundle
│   ├── vks-source-cluster.yaml     # Tanzu Cluster API manifest for vks-source
│   └── vks-cluster.yaml            # Tanzu Cluster API manifest for vks-target
├── scripts/
│   ├── Generate-VideoDemo.ps1      # Automated Chrome headless + ffmpeg video builder
│   └── s3-helper.ps1               # Pure PowerShell AWS SigV4 client for MinIO S3
└── assets/
    ├── media/
    │   └── k8s_migration_demo.mp4  # 1080p Full HD video recording (1m 37s)
    └── images/                     # Video chapter stills and slide captures
```

---

## 🚀 Quickstart & Reproduction

### 1. Zero-Copy FCD Volume Adoption (Pattern 1)
```bash
# 1. Scale down workload on source cluster
kubectl --kubeconfig=vks-source.kubeconfig scale statefulset payments-db --replicas=0 -n migration-demo

# 2. Patch source PV reclaimPolicy to Retain and delete source PVC
kubectl --kubeconfig=vks-source.kubeconfig patch pv <source-pv> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl --kubeconfig=vks-source.kubeconfig delete pvc data-payments-db-0 -n migration-demo

# 3. Apply static Paravirtual CSI PV & PVC on target cluster
kubectl --kubeconfig=vks-target.kubeconfig apply -f manifests/adopted-fcd-pv.yaml

# 4. Reconcile Helm chart release
helm --kubeconfig=vks-target.kubeconfig upgrade --install payments-db ./helm/payments-db-chart -n migration-demo --take-ownership
```

### 2. Velero + MinIO S3 Backup & Restore (Pattern 3)
```bash
# 1. Take namespace backup on vks-source
velero backup create payments-db-velero-v1 \
  --kubeconfig=vks-source.kubeconfig \
  --include-namespaces migration-demo \
  --default-volumes-to-fs-backup=true --wait

# 2. Restore into target cluster with namespace remapping
velero restore create restore-payments-db-velero-v1 \
  --kubeconfig=vks-target.kubeconfig \
  --from-backup payments-db-velero-v1 \
  --namespace-mappings migration-demo:demo-velero --wait
```

### 3. Verify Database Integrity
```bash
kubectl --kubeconfig=vks-target.kubeconfig exec -i payments-db-0 -n <target-namespace> -- \
  psql -U payadmin -d payments -c "SELECT * FROM migration_integrity_summary;"
```
Expected output:
```text
 total_rows | min_id | max_id | total_amount |        aggregate_checksum        
------------+--------+--------+--------------+----------------------------------
       5000 |      1 |   5000 |   3767875.00 | c318e5f2f42f3fb6d4da7b7371a6191e
```

---

## 📜 License & Acknowledgments
Created as part of VMware Cloud Foundation (VCF) 9.1 technical validation by Broadcom. Open-sourced under the Apache 2.0 License.
