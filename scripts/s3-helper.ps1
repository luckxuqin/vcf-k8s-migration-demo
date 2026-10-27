# S3 SigV4 client in pure PowerShell
param(
    [string]$Endpoint = "https://10.163.44.130:9000",
    [string]$AccessKey = "KsSYGk8C9JjmlL1CkTo8",
    [string]$SecretKey = "9vgnG8mHjnzICBzwD6gjyyqdFzt7xDjQwLZQDkQ4",
    [string]$Region = "us-east-1",
    [string]$BucketName = "velero-backups",
    [string]$Method = "PUT"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

function HmacSHA256([byte[]]$key, [string]$data) {
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $key
    return $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($data))
}

function HashSHA256([string]$data) {
    $sha = New-Object System.Security.Cryptography.SHA256Managed
    $bytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($data))
    return -join ($bytes | ForEach-Object { "{0:x2}" -f $_ })
}

$now = [DateTime]::UtcNow
$amzDate = $now.ToString("yyyyMMddTHHmmssZ")
$dateStamp = $now.ToString("yyyyMMdd")

$uri = New-Object System.Uri("$Endpoint/$BucketName")
$canonicalUri = "/$BucketName"
$canonicalQuery = ""

$payloadHash = HashSHA256 ""
$hostHeader = $uri.Host + ":" + $uri.Port
$canonicalHeaders = "host:$hostHeader`nx-amz-content-sha256:$payloadHash`nx-amz-date:$amzDate`n"
$signedHeaders = "host;x-amz-content-sha256;x-amz-date"

$canonicalRequest = "$Method`n$canonicalUri`n$canonicalQuery`n$canonicalHeaders`n$signedHeaders`n$payloadHash"
$stringToSign = "AWS4-HMAC-SHA256`n$amzDate`n$dateStamp/$Region/s3/aws4_request`n" + (HashSHA256 $canonicalRequest)

$kSecret = [System.Text.Encoding]::UTF8.GetBytes("AWS4" + $SecretKey)
$kDate = HmacSHA256 $kSecret $dateStamp
$kRegion = HmacSHA256 $kDate $Region
$kService = HmacSHA256 $kRegion "s3"
$kSigning = HmacSHA256 $kService "aws4_request"

$signatureBytes = HmacSHA256 $kSigning $stringToSign
$signature = -join ($signatureBytes | ForEach-Object { "{0:x2}" -f $_ })

$authHeader = "AWS4-HMAC-SHA256 Credential=$AccessKey/$dateStamp/$Region/s3/aws4_request, SignedHeaders=$signedHeaders, Signature=$signature"

$req = [System.Net.HttpWebRequest]::Create($uri)
$req.Method = $Method
$req.Headers["x-amz-date"] = $amzDate
$req.Headers["x-amz-content-sha256"] = $payloadHash
$req.Headers["Authorization"] = $authHeader
$req.ContentLength = 0

try {
    $resp = $req.GetResponse()
    Write-Host "Success: $($resp.StatusCode)"
    $resp.Close()
} catch [System.Net.WebException] {
    if ($_.Response) {
        $stream = $_.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $body = $reader.ReadToEnd()
        Write-Host "Error response: $body"
    } else {
        Write-Host "Error: $($_.Message)"
    }
}
