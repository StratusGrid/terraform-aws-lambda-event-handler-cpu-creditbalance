# To Do #
# add try catch to volume query (and general error handling?)
# abstract function code from terraform module and variablize pattern somehow?
# add an instantiation check for new containers that checks all instances and updates the settings?

# MAKE DELETE CHECK EXIST FIRST AND NOT CHECK GP2


# Import libraries
import boto3
import re
import os

#Function to create alarm for Standard Burst instances
def create_standard_alarm(instance_id):
  print('Creating standard alarm for instance: ', instance_id)
  response = cloudwatch.put_metric_alarm(
    AlarmName="{0}-CpuCreditBalance".format(instance_id),
    AlarmDescription='Alarm when CPU Credit Balance below threshold',
    ActionsEnabled=True,
    AlarmActions=[
      os.environ['sns_alarm_target']
    ],
    MetricName='CPUCreditBalance',
    Namespace='AWS/EC2',
    Statistic='Average',
    Dimensions=[
      {
        'Name': 'InstanceId',
        'Value': instance_id
      },
    ],
    Period=int(os.environ['alarm_period']),
    EvaluationPeriods=1,
    Threshold=float(os.environ['alarm_threshold_standard']),
    ComparisonOperator='LessThanOrEqualToThreshold'
    )
  # Verify successful
  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    print('Successfully created standard CpuCreditBalance Alarm for instance: ', instance_id)
  # Else print response as error
  else:
    print(response)

#Function to delete alarm for Standard Burst instances
def delete_standard_alarm(instance_id):
  print('Deleting alarm for instance: ', instance_id)
  response = cloudwatch.delete_alarms(
    AlarmNames=[
      "{0}-CpuCreditBalance".format(instance_id)
      ]
    )
  # Verify successful
  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    print('Successfully deleted CpuCreditBalance Alarm for instance: ', instance_id)
  # Else print response as error
  else:
    print(response)

#Function to create alarm for Unlimited Burst instances
def create_unlimited_alarm(instance_id):
  print('Creating unlimited alarm for instance: ', instance_id)
  response = cloudwatch.put_metric_alarm(
    AlarmName="{0}-CPUSurplusCreditBalance".format(instance_id),
    AlarmDescription='Alarm when CPU Surplus Credit Balance above threshold',
    ActionsEnabled=True,
    AlarmActions=[
      os.environ['sns_alarm_target']
    ],
    MetricName='CPUSurplusCreditBalance',
    Namespace='AWS/EC2',
    Statistic='Average',
    Dimensions=[
      {
        'Name': 'InstanceId',
        'Value': instance_id
      },
    ],
    Period=int(os.environ['alarm_period']),
    EvaluationPeriods=1,
    Threshold=float(os.environ['alarm_threshold_unlimited']),
    ComparisonOperator='GreaterThanOrEqualToThreshold'
    )
  # Verify successful
  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    print('Successfully created unlimited CPUSurplusCreditBalance Alarm for instance: ', instance_id)
  # Else print response as error
  else:
    print(response)

#Function to delete alarm for Unlimited Burst instances
def delete_unlimited_alarm(instance_id):
  print('Deleting alarm for instance: ', instance_id)
  response = cloudwatch.delete_alarms(
    AlarmNames=[
      "{0}-CPUSurplusCreditBalance".format(instance_id)
      ]
    )
  # Verify successful
  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    print('Successfully deleted CPUSurplusCreditBalance Alarm for instance: ', instance_id)
  # Else print response as error
  else:
    print(response)


# Initialize boto3 clients (since this is outside of the handler function, it will only be done once per container)
cloudwatch = boto3.client('cloudwatch')
ec2 = boto3.client('ec2')

# Entry point for lambda
def handler(event, context):

  # instance creation event
  if event['detail']['state'] == 'running':
    # Pull instance from resource by regex group i-.*
    for resource in event['resources']:
      match_instance = re.match(r'.*(i-.*)$', resource)
      instance_id = match_instance.group(1)
      if match_instance:
        # Get instance information and record type
        instance = ec2.describe_instances(InstanceIds=[instance_id])
        instance_type = instance['Reservations'][0]['Instances'][0]['InstanceType']
        # If InstanceType starts with t
        match_instance_type = re.match(r'^t\d\..*$', instance_type)
        # Determine whether resource is standard or unlimited and execute correct alarm creation function
        if match_instance_type:
          credit_specifications = ec2.describe_instance_credit_specifications(InstanceIds=[instance_id])
          credit_type = credit_specifications['InstanceCreditSpecifications'][0]['CpuCredits']
          if credit_type == 'standard':
            create_standard_alarm(instance_id)
          if credit_type == 'unlimited':
            create_unlimited_alarm(instance_id)
          

  # instance Stopped/Terminated event
  if (event['detail']['state'] == 'stopped') or (event['detail']['state'] == 'terminated'):
    # Pull instance from resource by regex group i-.*
    for resource in event['resources']:
      match_instance = re.match(r'.*(i-.*)$', resource)
      instance_id = match_instance.group(1)
      if match_instance:
        # Get instance information and record type
        instance = ec2.describe_instances(InstanceIds=[instance_id])
        instance_type = instance['Reservations'][0]['Instances'][0]['InstanceType']
        # If InstanceType starts with t
        match_instance_type = re.match(r'^t\d\..*$', instance_type)
        # Attempt to delete CloudWatch Alarm
        if match_instance_type:
          credit_specifications = ec2.describe_instance_credit_specifications(InstanceIds=[instance_id])
          credit_type = credit_specifications['InstanceCreditSpecifications'][0]['CpuCredits']
          if credit_type == 'standard':
            delete_standard_alarm(instance_id)
          if credit_type == 'unlimited':
            delete_unlimited_alarm(instance_id)
