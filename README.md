change for demo.
# AMI build with packer

# Validate json with Packer 

provide variables with a file.
<code>
    packer validate -var-file ami.json
</code>

provide variables inline.
<code>
    packer validate -var "ami_users=REACTED" ami.json
</code>


# Build ami with Packer 

provide variables with a file.
<code>
    packer build -var-file ami.json
</code>

provide variables inline.
<code>
    packer build -var "ami_users=REACTED" ami.json
</code>