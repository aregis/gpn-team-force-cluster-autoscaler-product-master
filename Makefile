export DOCKER_BUILDKIT=1
AWS_DEFAULT_REGION?=us-east-2
PROJECT=gpn-team-force-cluster-autoscaler
flags?=
TF_LOG?=TRACE
TF_IGNORE?=trace

# BUILD
build-%:
	docker build \
	$(flags) \
	-t $(PROJECT):$* \
	--target $* .

# DEVELOP
develop:
	make build-test flags=$(flags)
	docker run -it --rm \
	-v $(PWD):/$(PROJECT) \
	-w /$(PROJECT) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	$(PROJECT):test ash

# TEST
init:
	docker run -i --rm \
	-v $(PWD):/$(PROJECT) \
	-w /$(PROJECT) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	$(PROJECT):test terraform -chdir=terraform init

plan:
	docker run -i --rm \
	-v $(PWD):/$(PROJECT) \
	-w /$(PROJECT) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	$(PROJECT):test terraform -chdir=terraform plan -out=plan.out

validate:
	docker run -i --rm \
	-v $(PWD):/$(PROJECT) \
	-w /$(PROJECT) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	$(PROJECT):test terraform -chdir=terraform validate -json

test: init lint

# DEPLOY
deploy:
	docker run -i --rm \
	-v $(PWD):/$(PROJECT) \
	-w /$(PROJECT) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	$(PROJECT):test terraform -chdir=terraform validate -json

	terraform -chdir=terraform apply "plan.out"

# CLEAN-UP
teardown:
	terraform -chdir=terraform plan -destroy
	terraform -chdir=terraform destroy

.PHONY: build develop test deploy
