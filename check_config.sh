#!/bin/bash

github_raw_url="https://raw.githubusercontent.com/$GIT_REPO/${TARGET_BRANCH#refs/heads/}/$CONFIG_FILE_PATH"
file_content=$(curl -sS $github_raw_url)

function readValue {
  echo "$file_content" | yq eval $1 -
}

# config 파일에 필요한 키가 존재하는지 여부 확인
required_keys=(".config.name" ".config.service_type")

for required_key in "${required_keys[@]}"; do
  if ! $(readValue "${required_key}"); then
    echo "Error: The specified key \"$required_key\" does not exist"
    exit 1
  fi
done

# service_domain 값이 존재하면서 .xquare.app으로 끝나지 않는 경우 에러
domain_key=".config.domain"
domain_value=$(readValue "${domain_key}")

if [[ ! $domain_value = "" && ! "$domain_value" =~ \.xquare\.app$ ]]; then
  echo "Error: The domain ($domain_value) does not end with '.xquare.app'."
  exit 1
fi

echo "name=$(readValue ".config.name")" 
echo "prefix=$(readValue ".config.prefix")"
echo "domain=$(readValue ".config.domain")"
echo "type=$(readValue ".config.service_type")"


echo "name=$(readValue ".config.name")" >> $GITHUB_ENV
echo "prefix=$(readValue ".config.prefix")" >> $GITHUB_ENV
echo "domain=$(readValue ".config.domain")" >> $GITHUB_ENV
echo "type=$(readValue ".config.service_type")" >> $GITHUB_ENV
