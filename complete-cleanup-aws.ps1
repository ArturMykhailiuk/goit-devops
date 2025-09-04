# Complete AWS Resource Cleanup Script - ALL RESOURCES
Write-Host "=== Complete AWS Resource Cleanup Script - ALL RESOURCES ===" -ForegroundColor Red

$region = "us-east-1"

Write-Host "⚠️  WARNING: This script will delete ALL AWS resources in region $region" -ForegroundColor Red
Write-Host "⚠️  This action cannot be undone!" -ForegroundColor Red
$confirmation = Read-Host "Type 'DELETE-ALL' to proceed"
if ($confirmation -ne "DELETE-ALL") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

Write-Host "Starting comprehensive cleanup for ALL resources" -ForegroundColor Cyan
Write-Host "Region: $region" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Cyan

try {
    # 1. Terminate ALL EC2 Instances
    Write-Host "`n1. Terminating ALL EC2 Instances..." -ForegroundColor Cyan
    $instances = aws ec2 describe-instances --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" --output text --region $region
    if ($instances) {
        foreach ($instance in $instances.Split()) {
            if ($instance.Trim()) {
                aws ec2 terminate-instances --instance-ids $instance --region $region
                Write-Host "Terminating instance: $instance" -ForegroundColor Yellow
            }
        }
        
        # Wait for instances to terminate
        Write-Host "Waiting for instances to terminate..." -ForegroundColor Yellow
        do {
            Start-Sleep -Seconds 30
            $runningInstances = aws ec2 describe-instances --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" --output text --region $region 2>$null
            Write-Host "." -NoNewline
        } while ($runningInstances)
        Write-Host "`nAll instances terminated!" -ForegroundColor Green
    }

    # 2. Clean ALL EKS Resources
    Write-Host "`n2. Cleaning ALL EKS Resources..." -ForegroundColor Cyan
    $clustersResult = aws eks list-clusters --query "clusters[]" --output text --region $region
    
    if ($clustersResult) {
        foreach ($cluster in $clustersResult.Split()) {
            if ($cluster -and $cluster.Trim()) {
                Write-Host "Processing EKS cluster: $cluster" -ForegroundColor Yellow
                
                # Delete Fargate profiles
                $fargateResult = aws eks list-fargate-profiles --cluster-name $cluster --query "fargateProfileNames[]" --output text --region $region 2>$null
                if ($fargateResult) {
                    foreach ($fargateProfile in $fargateResult.Split()) {
                        if ($fargateProfile -and $fargateProfile.Trim()) {
                            aws eks delete-fargate-profile --cluster-name $cluster --fargate-profile-name $fargateProfile --region $region
                            Write-Host "Deleted Fargate profile: $fargateProfile" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete addons
                $addonsResult = aws eks list-addons --cluster-name $cluster --query "addons[]" --output text --region $region 2>$null
                if ($addonsResult) {
                    foreach ($addon in $addonsResult.Split()) {
                        if ($addon -and $addon.Trim()) {
                            aws eks delete-addon --cluster-name $cluster --addon-name $addon --region $region
                            Write-Host "Deleted addon: $addon" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete node groups
                $nodeGroupsResult = aws eks list-nodegroups --cluster-name $cluster --query "nodegroups[]" --output text --region $region 2>$null
                if ($nodeGroupsResult) {
                    foreach ($ng in $nodeGroupsResult.Split()) {
                        if ($ng -and $ng.Trim()) {
                            aws eks delete-nodegroup --cluster-name $cluster --nodegroup-name $ng --region $region
                            Write-Host "Deleted node group: $ng" -ForegroundColor Yellow
                        }
                    }
                    
                    # Wait for node groups to delete
                    Write-Host "Waiting for node groups to delete..." -ForegroundColor Yellow
                    do {
                        Start-Sleep -Seconds 30
                        $remainingNodeGroups = aws eks list-nodegroups --cluster-name $cluster --query "nodegroups[]" --output text --region $region 2>$null
                        Write-Host "." -NoNewline
                    } while ($remainingNodeGroups)
                    Write-Host "`nNode groups deleted!" -ForegroundColor Green
                }
                
                # Delete cluster
                aws eks delete-cluster --name $cluster --region $region
                Write-Host "Deleted EKS cluster: $cluster" -ForegroundColor Green
            }
        }
    }

    # 3. Clean ALL Load Balancers and Target Groups
    Write-Host "`n3. Cleaning ALL Load Balancers..." -ForegroundColor Cyan
    
    # Delete Classic Load Balancers (ELBv1)
    $classicLBs = aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text --region $region 2>$null
    if ($classicLBs) {
        foreach ($classicLB in $classicLBs.Split()) {
            if ($classicLB -and $classicLB.Trim()) {
                aws elb delete-load-balancer --load-balancer-name $classicLB --region $region 2>$null
                Write-Host "Deleted Classic Load Balancer: $classicLB" -ForegroundColor Green
            }
        }
    }
    
    # Get ALL Application/Network Load Balancers (ELBv2)
    $allLBs = aws elbv2 describe-load-balancers --query "LoadBalancers[]" --output json --region $region | ConvertFrom-Json
    
    foreach ($lb in $allLBs) {
        # Delete listeners first
        $listeners = aws elbv2 describe-listeners --load-balancer-arn $lb.LoadBalancerArn --query "Listeners[].ListenerArn" --output text --region $region
        foreach ($listener in $listeners.Split()) {
            if ($listener.Trim()) {
                aws elbv2 delete-listener --listener-arn $listener --region $region
            }
        }
        
        # Delete load balancer
        aws elbv2 delete-load-balancer --load-balancer-arn $lb.LoadBalancerArn --region $region
        Write-Host "Deleted Load Balancer: $($lb.LoadBalancerName)" -ForegroundColor Green
    }

    # Delete ALL Target Groups
    $targetGroupsResult = aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn" --output text --region $region 2>$null
    if ($targetGroupsResult) {
        foreach ($targetGroup in $targetGroupsResult.Split()) {
            if ($targetGroup -and $targetGroup.Trim()) {
                aws elbv2 delete-target-group --target-group-arn $targetGroup --region $region 2>$null
                Write-Host "Deleted Target Group: $targetGroup" -ForegroundColor Green
            }
        }
    }

    # 4. Clean ALL RDS Resources
    Write-Host "`n4. Cleaning ALL RDS Resources..." -ForegroundColor Cyan
    
    # ALL Aurora Clusters
    $clusters = aws rds describe-db-clusters --query "DBClusters[]" --output json --region $region | ConvertFrom-Json
    foreach ($cluster in $clusters) {
        # Delete cluster instances first
        foreach ($member in $cluster.DBClusterMembers) {
            aws rds delete-db-instance --db-instance-identifier $member.DBInstanceIdentifier --skip-final-snapshot --region $region
            Write-Host "Deleting cluster instance: $($member.DBInstanceIdentifier)" -ForegroundColor Yellow
        }
        
        # Wait for instances to delete
        Start-Sleep -Seconds 60
        
        # Delete cluster
        aws rds delete-db-cluster --db-cluster-identifier $cluster.DBClusterIdentifier --skip-final-snapshot --region $region
        Write-Host "Deleted RDS Cluster: $($cluster.DBClusterIdentifier)" -ForegroundColor Green
    }
    
    # ALL Standalone RDS Instances
    $instances = aws rds describe-db-instances --query "DBInstances[]" --output json --region $region | ConvertFrom-Json
    foreach ($instance in $instances) {
        aws rds delete-db-instance --db-instance-identifier $instance.DBInstanceIdentifier --skip-final-snapshot --region $region
        Write-Host "Deleted RDS Instance: $($instance.DBInstanceIdentifier)" -ForegroundColor Green
    }

    # Delete ALL RDS Snapshots (manual)
    $snapshotsResult = aws rds describe-db-snapshots --query "DBSnapshots[].DBSnapshotIdentifier" --output text --region $region 2>$null
    if ($snapshotsResult) {
        foreach ($snapshot in $snapshotsResult.Split()) {
            if ($snapshot -and $snapshot.Trim()) {
                aws rds delete-db-snapshot --db-snapshot-identifier $snapshot --region $region 2>$null
                Write-Host "Deleted RDS Snapshot: $snapshot" -ForegroundColor Green
            }
        }
    }

    # Delete ALL RDS Cluster Snapshots
    $clusterSnapshotsResult = aws rds describe-db-cluster-snapshots --query "DBClusterSnapshots[].DBClusterSnapshotIdentifier" --output text --region $region 2>$null
    if ($clusterSnapshotsResult) {
        foreach ($clusterSnapshot in $clusterSnapshotsResult.Split()) {
            if ($clusterSnapshot -and $clusterSnapshot.Trim()) {
                aws rds delete-db-cluster-snapshot --db-cluster-snapshot-identifier $clusterSnapshot --region $region 2>$null
                Write-Host "Deleted RDS Cluster Snapshot: $clusterSnapshot" -ForegroundColor Green
            }
        }
    }

    # Delete ALL RDS Subnet Groups (except default)
    $subnetGroupsResult = aws rds describe-db-subnet-groups --query "DBSubnetGroups[?DBSubnetGroupName != 'default'].DBSubnetGroupName" --output text --region $region 2>$null
    if ($subnetGroupsResult) {
        foreach ($subnetGroup in $subnetGroupsResult.Split()) {
            if ($subnetGroup -and $subnetGroup.Trim()) {
                aws rds delete-db-subnet-group --db-subnet-group-name $subnetGroup --region $region 2>$null
                Write-Host "Deleted RDS Subnet Group: $subnetGroup" -ForegroundColor Green
            }
        }
    }

    # Delete ALL RDS Parameter Groups (custom only)
    $parameterGroupsResult = aws rds describe-db-parameter-groups --query "DBParameterGroups[?!starts_with(DBParameterGroupName, 'default.')].DBParameterGroupName" --output text --region $region 2>$null
    if ($parameterGroupsResult) {
        foreach ($parameterGroup in $parameterGroupsResult.Split()) {
            if ($parameterGroup -and $parameterGroup.Trim()) {
                aws rds delete-db-parameter-group --db-parameter-group-name $parameterGroup --region $region 2>$null
                Write-Host "Deleted RDS Parameter Group: $parameterGroup" -ForegroundColor Green
            }
        }
    }

    # Delete ALL RDS Cluster Parameter Groups (custom only)
    $clusterParameterGroupsResult = aws rds describe-db-cluster-parameter-groups --query "DBClusterParameterGroups[?!starts_with(DBClusterParameterGroupName, 'default.')].DBClusterParameterGroupName" --output text --region $region 2>$null
    if ($clusterParameterGroupsResult) {
        foreach ($clusterParameterGroup in $clusterParameterGroupsResult.Split()) {
            if ($clusterParameterGroup -and $clusterParameterGroup.Trim()) {
                aws rds delete-db-cluster-parameter-group --db-cluster-parameter-group-name $clusterParameterGroup --region $region 2>$null
                Write-Host "Deleted RDS Cluster Parameter Group: $clusterParameterGroup" -ForegroundColor Green
            }
        }
    }

    # Delete ALL RDS Option Groups (custom only)
    $optionGroupsResult = aws rds describe-option-groups --query "OptionGroupsList[?!starts_with(OptionGroupName, 'default:')].OptionGroupName" --output text --region $region 2>$null
    if ($optionGroupsResult) {
        foreach ($optionGroup in $optionGroupsResult.Split()) {
            if ($optionGroup -and $optionGroup.Trim()) {
                aws rds delete-option-group --option-group-name $optionGroup --region $region 2>$null
                Write-Host "Deleted RDS Option Group: $optionGroup" -ForegroundColor Green
            }
        }
    }

    # 5. Clean ALL EBS Volumes
    Write-Host "`n5. Cleaning ALL EBS Volumes..." -ForegroundColor Cyan
    
    # Find ALL available volumes
    $ebsVolumesResult = aws ec2 describe-volumes --query "Volumes[?State=='available'].VolumeId" --output text --region $region 2>$null
    if ($ebsVolumesResult) {
        foreach ($volumeId in $ebsVolumesResult.Split()) {
            if ($volumeId -and $volumeId.Trim()) {
                aws ec2 delete-volume --volume-id $volumeId --region $region 2>$null
                Write-Host "Deleted EBS Volume: $volumeId" -ForegroundColor Green
            }
        }
    }

    # 6. Clean ALL VPC Resources (except default VPC)
    Write-Host "`n6. Cleaning ALL VPC Resources..." -ForegroundColor Cyan
    $vpcsResult = aws ec2 describe-vpcs --query "Vpcs[?!IsDefault].VpcId" --output text --region $region
    
    if ($vpcsResult) {
        foreach ($vpcId in $vpcsResult.Split()) {
            if ($vpcId -and $vpcId.Trim()) {
                Write-Host "Cleaning VPC: $vpcId" -ForegroundColor Yellow
                
                # Delete VPC Endpoints
                $endpointsResult = aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpcId" --query "VpcEndpoints[].VpcEndpointId" --output text --region $region 2>$null
                if ($endpointsResult) {
                    foreach ($endpoint in $endpointsResult.Split()) {
                        if ($endpoint -and $endpoint.Trim()) {
                            aws ec2 delete-vpc-endpoint --vpc-endpoint-id $endpoint --region $region
                            Write-Host "Deleted VPC Endpoint: $endpoint" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete NAT Gateways
                $natGatewaysResult = aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpcId" --query "NatGateways[?State=='available'].NatGatewayId" --output text --region $region 2>$null
                if ($natGatewaysResult) {
                    foreach ($nat in $natGatewaysResult.Split()) {
                        if ($nat -and $nat.Trim()) {
                            aws ec2 delete-nat-gateway --nat-gateway-id $nat --region $region
                            Write-Host "Deleting NAT Gateway: $nat" -ForegroundColor Yellow
                        }
                    }
                    
                    # Wait for NAT Gateways to delete
                    Write-Host "Waiting for NAT Gateways to delete..." -ForegroundColor Yellow
                    do {
                        Start-Sleep -Seconds 30
                        $remainingNats = aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpcId" --query "NatGateways[?State=='deleting' || State=='available'].NatGatewayId" --output text --region $region 2>$null
                        Write-Host "." -NoNewline
                    } while ($remainingNats)
                    Write-Host "`nNAT Gateways deleted!" -ForegroundColor Green
                }
                
                # Release Elastic IPs
                $eipsResult = aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null].AllocationId" --output text --region $region 2>$null
                if ($eipsResult) {
                    foreach ($eip in $eipsResult.Split()) {
                        if ($eip -and $eip.Trim()) {
                            aws ec2 release-address --allocation-id $eip --region $region
                            Write-Host "Released EIP: $eip" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete Internet Gateways
                $igwsResult = aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpcId" --query "InternetGateways[].InternetGatewayId" --output text --region $region 2>$null
                if ($igwsResult) {
                    foreach ($igw in $igwsResult.Split()) {
                        if ($igw -and $igw.Trim()) {
                            aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpcId --region $region
                            aws ec2 delete-internet-gateway --internet-gateway-id $igw --region $region
                            Write-Host "Deleted Internet Gateway: $igw" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete Security Groups (except default)
                $sgsResult = aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcId" --query "SecurityGroups[?GroupName != 'default'].GroupId" --output text --region $region 2>$null
                if ($sgsResult) {
                    foreach ($sg in $sgsResult.Split()) {
                        if ($sg -and $sg.Trim()) {
                            # Remove all rules first
                            try {
                                $inboundRulesJson = aws ec2 describe-security-groups --group-ids $sg --query "SecurityGroups[0].IpPermissions" --output json --region $region 2>$null
                                if ($inboundRulesJson -and $inboundRulesJson -ne "[]" -and $inboundRulesJson -ne "null") {
                                    $inboundRules = $inboundRulesJson | ConvertFrom-Json
                                    if ($inboundRules -and $inboundRules.Count -gt 0) {
                                        aws ec2 revoke-security-group-ingress --group-id $sg --ip-permissions ($inboundRules | ConvertTo-Json -Depth 10) --region $region 2>$null
                                    }
                                }
                                
                                $outboundRulesJson = aws ec2 describe-security-groups --group-ids $sg --query "SecurityGroups[0].IpPermissionsEgress" --output json --region $region 2>$null
                                if ($outboundRulesJson -and $outboundRulesJson -ne "[]" -and $outboundRulesJson -ne "null") {
                                    $outboundRules = $outboundRulesJson | ConvertFrom-Json
                                    if ($outboundRules -and $outboundRules.Count -gt 0) {
                                        aws ec2 revoke-security-group-egress --group-id $sg --ip-permissions ($outboundRules | ConvertTo-Json -Depth 10) --region $region 2>$null
                                    }
                                }
                                
                                aws ec2 delete-security-group --group-id $sg --region $region 2>$null
                                Write-Host "Deleted Security Group: $sg" -ForegroundColor Yellow
                            }
                            catch {
                                Write-Host "Failed to delete Security Group: $sg (may have dependencies)" -ForegroundColor Red
                            }
                        }
                    }
                }
                
                # Delete Subnets
                $subnetsResult = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text --region $region 2>$null
                if ($subnetsResult) {
                    foreach ($subnet in $subnetsResult.Split()) {
                        if ($subnet -and $subnet.Trim()) {
                            aws ec2 delete-subnet --subnet-id $subnet --region $region
                            Write-Host "Deleted Subnet: $subnet" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete Route Tables (except main)
                $routeTablesResult = aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpcId" --query "RouteTables[?!Associations[?Main==true]].RouteTableId" --output text --region $region 2>$null
                if ($routeTablesResult) {
                    foreach ($rt in $routeTablesResult.Split()) {
                        if ($rt -and $rt.Trim()) {
                            aws ec2 delete-route-table --route-table-id $rt --region $region
                            Write-Host "Deleted Route Table: $rt" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Delete Network ACLs (except default)
                $naclsResult = aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$vpcId" --query "NetworkAcls[?!IsDefault].NetworkAclId" --output text --region $region 2>$null
                if ($naclsResult) {
                    foreach ($nacl in $naclsResult.Split()) {
                        if ($nacl -and $nacl.Trim()) {
                            aws ec2 delete-network-acl --network-acl-id $nacl --region $region
                            Write-Host "Deleted Network ACL: $nacl" -ForegroundColor Yellow
                        }
                    }
                }
                
                # Finally delete VPC
                aws ec2 delete-vpc --vpc-id $vpcId --region $region
                Write-Host "Deleted VPC: $vpcId" -ForegroundColor Green
            }
        }
    }

    # 7. Clean ALL ECR Repositories
    Write-Host "`n7. Cleaning ALL ECR Repositories..." -ForegroundColor Cyan
    $reposResult = aws ecr describe-repositories --query "repositories[].repositoryName" --output text --region $region 2>$null
    if ($reposResult) {
        foreach ($repo in $reposResult.Split()) {
            if ($repo -and $repo.Trim()) {
                aws ecr delete-repository --repository-name $repo --force --region $region
                Write-Host "Deleted ECR Repository: $repo" -ForegroundColor Green
            }
        }
    }

    # 8. Clean ALL S3 Buckets
    Write-Host "`n8. Cleaning ALL S3 Buckets..." -ForegroundColor Cyan
    $bucketsResult = aws s3api list-buckets --query "Buckets[].Name" --output text 2>$null
    if ($bucketsResult) {
        foreach ($bucket in $bucketsResult.Split()) {
            if ($bucket -and $bucket.Trim()) {
                Write-Host "Emptying and deleting S3 bucket: $bucket" -ForegroundColor Yellow
                aws s3 rm s3://$bucket --recursive 2>$null
                aws s3api delete-bucket --bucket $bucket 2>$null
                Write-Host "Deleted S3 Bucket: $bucket" -ForegroundColor Green
            }
        }
    }

    # 9. Clean ALL DynamoDB Tables
    Write-Host "`n9. Cleaning ALL DynamoDB Tables..." -ForegroundColor Cyan
    $tablesResult = aws dynamodb list-tables --query "TableNames[]" --output text --region $region 2>$null
    if ($tablesResult) {
        foreach ($table in $tablesResult.Split()) {
            if ($table -and $table.Trim()) {
                aws dynamodb delete-table --table-name $table --region $region
                Write-Host "Deleted DynamoDB Table: $table" -ForegroundColor Green
            }
        }
    }

    # 10. Clean ALL IAM Resources
    Write-Host "`n10. Cleaning ALL IAM Resources..." -ForegroundColor Cyan
    $rolesResult = aws iam list-roles --query "Roles[?!starts_with(RoleName, 'AWS') && !starts_with(RoleName, 'OrganizationAccountAccessRole')].RoleName" --output text 2>$null
    if ($rolesResult) {
        foreach ($role in $rolesResult.Split()) {
            if ($role -and $role.Trim()) {
                # Detach all policies
                $attachedPoliciesResult = aws iam list-attached-role-policies --role-name $role --query "AttachedPolicies[].PolicyArn" --output text 2>$null
                if ($attachedPoliciesResult) {
                    foreach ($policy in $attachedPoliciesResult.Split()) {
                        if ($policy -and $policy.Trim()) {
                            aws iam detach-role-policy --role-name $role --policy-arn $policy 2>$null
                        }
                    }
                }
                
                # Delete inline policies
                $inlinePoliciesResult = aws iam list-role-policies --role-name $role --query "PolicyNames[]" --output text 2>$null
                if ($inlinePoliciesResult) {
                    foreach ($policy in $inlinePoliciesResult.Split()) {
                        if ($policy -and $policy.Trim()) {
                            aws iam delete-role-policy --role-name $role --policy-name $policy 2>$null
                        }
                    }
                }
                
                # Delete instance profiles
                $instanceProfilesResult = aws iam list-instance-profiles-for-role --role-name $role --query "InstanceProfiles[].InstanceProfileName" --output text 2>$null
                if ($instanceProfilesResult) {
                    foreach ($instanceProfile in $instanceProfilesResult.Split()) {
                        if ($instanceProfile -and $instanceProfile.Trim()) {
                            aws iam remove-role-from-instance-profile --instance-profile-name $instanceProfile --role-name $role 2>$null
                            aws iam delete-instance-profile --instance-profile-name $instanceProfile 2>$null
                        }
                    }
                }
                
                aws iam delete-role --role-name $role 2>$null
                Write-Host "Deleted IAM Role: $role" -ForegroundColor Green
            }
        }
    }

    # 11. Clean ALL OIDC Providers
    Write-Host "`n11. Cleaning ALL OIDC Providers..." -ForegroundColor Cyan
    $oidcProvidersResult = aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[].Arn" --output text 2>$null
    if ($oidcProvidersResult) {
        foreach ($provider in $oidcProvidersResult.Split()) {
            if ($provider -and $provider.Trim()) {
                aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $provider 2>$null
                Write-Host "Deleted OIDC Provider: $provider" -ForegroundColor Green
            }
        }
    }

    # 12. Clean ALL KMS Keys
    Write-Host "`n12. Cleaning ALL KMS Keys..." -ForegroundColor Cyan
    $kmsKeysResult = aws kms list-keys --query "Keys[].KeyId" --output text --region $region 2>$null
    if ($kmsKeysResult) {
        foreach ($keyId in $kmsKeysResult.Split()) {
            if ($keyId -and $keyId.Trim()) {
                # Get key details to check if customer managed
                $keyDetails = aws kms describe-key --key-id $keyId --query "KeyMetadata" --output json --region $region 2>$null | ConvertFrom-Json
                if ($keyDetails -and $keyDetails.KeyManager -eq "CUSTOMER") {
                    # Schedule key deletion (minimum 7 days)
                    aws kms schedule-key-deletion --key-id $keyId --pending-window-in-days 7 --region $region 2>$null
                    Write-Host "Scheduled KMS Key deletion: $keyId" -ForegroundColor Green
                }
            }
        }
    }

    # 13. Clean ALL CloudWatch Resources
    Write-Host "`n13. Cleaning ALL CloudWatch Resources..." -ForegroundColor Cyan
    $logGroupsResult = aws logs describe-log-groups --query "logGroups[].logGroupName" --output text --region $region 2>$null
    if ($logGroupsResult) {
        foreach ($logGroup in $logGroupsResult.Split()) {
            if ($logGroup -and $logGroup.Trim()) {
                aws logs delete-log-group --log-group-name $logGroup --region $region 2>$null
                Write-Host "Deleted Log Group: $logGroup" -ForegroundColor Green
            }
        }
    }

    # 14. Clean ALL Lambda Functions
    Write-Host "`n14. Cleaning ALL Lambda Functions..." -ForegroundColor Cyan
    $functions = aws lambda list-functions --query "Functions[].FunctionName" --output text --region $region 2>$null
    if ($functions) {
        foreach ($func in $functions.Split()) {
            if ($func.Trim()) {
                aws lambda delete-function --function-name $func --region $region 2>$null
                Write-Host "Deleted Lambda function: $func" -ForegroundColor Green
            }
        }
    }

    Write-Host "`n=== Complete cleanup finished successfully! ===" -ForegroundColor Green
    Write-Host "ALL AWS resources in region $region have been cleaned up." -ForegroundColor Green

}
catch {
    Write-Host "`nError during cleanup: $_" -ForegroundColor Red
    Write-Host "Some resources may need manual cleanup." -ForegroundColor Yellow
}

Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
Read-Host
