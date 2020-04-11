#
# This script should be run from the repo's deployment directory
# cd deployment
# ./build-s3-dist.sh source-bucket-base-name solution-name version-code template-bucket-name
#
# Parameters:
#  - source-bucket-base-name: Name for the S3 bucket location where the template will source the Lambda
#    code from. The template will append '-[region_name]' to this bucket name.
#    For example: ./build-s3-dist.sh solutions my-solution v1.0.0
#    The template will then expect the source code to be located in the solutions-[region_name] bucket
#
#  - solution-name: name of the solution for consistency
#
#  - version-code: version of the package
#
#  - template-bucket-name: Name for S3 bucket location where the template will be located in.

# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Please provide the base source bucket name, trademark approved solution name and version where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions trademarked-solution-name v1.0.0 solutions-reference"
    exit 1
fi

# Get reference for all important folders
template_dir="$PWD"
template_dist_dir="$template_dir/global-s3-assets"
build_dist_dir="$template_dir/regional-s3-assets"
source_dir="$template_dir/../source"

echo "------------------------------------------------------------------------------"
echo "[Init] Clean old dist, node_modules and bower_components folders"
echo "------------------------------------------------------------------------------"
echo "rm -rf $template_dist_dir"
rm -rf $template_dist_dir
echo "mkdir -p $template_dist_dir"
mkdir -p $template_dist_dir
echo "rm -rf $build_dist_dir"
rm -rf $build_dist_dir
echo "mkdir -p $build_dist_dir"
mkdir -p $build_dist_dir

echo "------------------------------------------------------------------------------"
echo "[Packing] Templates"
echo "------------------------------------------------------------------------------"
echo "cp $template_dir/*.template $template_dist_dir/"
cp $template_dir/*.template $template_dist_dir/
echo "copy yaml templates and rename"
cp $template_dir/*.yaml $template_dist_dir/
cd $template_dist_dir
# Rename all *.yaml to *.template
for f in *.yaml; do
    mv -- "$f" "${f%.yaml}.template"
done

cd ..
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Updating code source bucket in template with $1"

    replace="s/%%BUCKET_NAME%%/$1/g"
    echo "sed -i '' -e $replace $template_dist_dir/*.template"
    sed -i '' -e $replace $template_dist_dir/*.template

    replace="s/%%SOLUTION_NAME%%/$2/g"
    echo "sed -i '' -e $replace $template_dist_dir/*.template"
    sed -i '' -e $replace $template_dist_dir/*.template

    replace="s/%%VERSION%%/$3/g"
    echo "sed -i '' -e $replace $template_dist_dir/*.template"
    sed -i '' -e $replace $template_dist_dir/*.template

    replace="s/%%TEMPLATE_BUCKET_NAME%%/$4/g"
    echo "sed -i '' -e $replace $template_dist_dir/*.template"
    sed -i '' -e $replace $template_dist_dir/*.template
else
    echo "Updating code source bucket in template with $1"

    replace="s/%%BUCKET_NAME%%/$1/g"
    echo "sed -i -e $replace $template_dist_dir/*.template"
    sed -i -e $replace $template_dist_dir/*.template

    replace="s/%%SOLUTION_NAME%%/$2/g"
    echo "sed -i -e $replace $template_dist_dir/*.template"
    sed -i -e $replace $template_dist_dir/*.template

    replace="s/%%VERSION%%/$3/g"
    echo "sed -i -e $replace $template_dist_dir/*.template"
    sed -i -e $replace $template_dist_dir/*.template

    replace="s/%%TEMPLATE_BUCKET_NAME%%/$4/g"
    echo "sed -i -e $replace $template_dist_dir/*.template"
    sed -i -e $replace $template_dist_dir/*.template
fi