$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function Get-Pool() {
    $processModel = @{
                        'userName' = ''; 
                        'password' = ''; 
                        'identityType' = '';
                    }

    return @{
                'processModel' = $processModel;
                'managedRuntimeVersion' = '';
            } 
}

Describe "CreateOrUpdate-AppPool" {
    Context "given pool already exists" {

        $pool1 = Get-Pool 

        Mock Get-Item -MockWith { return $pool1 }
        Mock Set-Item -MockWith { }
        Mock Write-Host -MockWith { }

        $poolName = 'test'
        $username = 'azure-user'
        $password = 'password'

        CreateOrUpdate-AppPool -poolName $poolName -username $username -password $password

        It "should update the username and password" {
            $pool1.processModel.username | Should Be $username
            $pool1.processModel.password | Should Be $password
            $pool1.processModel.identityType | Should Be 'SpecificUser'
        }

        It "should update the runtime to v4.0" {
            $pool1.managedRuntimeVersion | Should Be 'v4.0'
        }
        
        It "should tell user that pool already existed" {
            Assert-MockCalled 'Write-Host' -Times 1 -ParameterFilter { $object -eq "$poolName pool already exists." }
        }

        It "should tell user that pool was successfully updated" {
            Assert-MockCalled 'Write-Host' -Times 1 -ParameterFilter { $object -eq "$poolName pool credentials updated successfully." }
        }
    }

    Context "given pool does not exist and can be successfully created" {

        $pool2 = Get-Pool

        Mock Get-Item -MockWith { return $null }
        Mock Set-Item -MockWith { }
        Mock New-WebAppPool -MockWith { return $pool2 }
        Mock Write-Host -MockWith { }

        $poolName = 'test'
        $username = 'azure-user'
        $password = 'password'

        CreateOrUpdate-AppPool -poolName $poolName -username $username -password $password

        It "should update the username and password" {
            $pool2.processModel.username | Should Be $username
            $pool2.processModel.password | Should Be $password
            $pool2.processModel.identityType | Should Be 'SpecificUser'
        }

        It "should update the runtime to v4.0" {
            $pool2.managedRuntimeVersion | Should Be 'v4.0'
        }

        It "should tell user that pool was successfully created" {
            Assert-MockCalled 'Write-Host' -Times 1 -ParameterFilter { $object -eq "$poolName pool was successfully created." }
        }

        It "should tell user that pool was successfully updated" {
            Assert-MockCalled 'Write-Host' -Times 1 -ParameterFilter { $object -eq "$poolName pool credentials updated successfully." }
        }
    }

    Context "given pool does not exist and can be successfully created" {

        Mock Get-Item -MockWith { return $null }
        Mock Set-Item -MockWith { }
        Mock New-WebAppPool -MockWith { return $null }
        Mock Write-Host -MockWith { }

        $poolName = 'test'
        $username = 'azure-user'
        $password = 'password'

        CreateOrUpdate-AppPool -poolName $poolName -username $username -password $password

        It "should tell user that pool failed to create" {
            Assert-MockCalled 'Write-Host' -Times 1 -ParameterFilter { $object -eq "$poolName pool failed to create." }
        }
    }
}

