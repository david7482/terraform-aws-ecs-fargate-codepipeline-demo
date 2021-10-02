check-%:
	@if [ "$(filter $*, staging rc production)" = "" ]; then \
		echo "Could not read valid environment: $* (Need to be 'staging', 'rc' or 'production')"; \
		exit 1;\
	fi

init:
	terraform init

plan-%: check-%
	terraform workspace select $*
	terraform plan -var-file configs/$*.tfvars

apply-%: check-%
	terraform workspace select $*
	terraform apply -var-file configs/$*.tfvars