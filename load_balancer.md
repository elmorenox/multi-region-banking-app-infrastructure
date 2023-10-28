# Create Application Load Balancer

Follow the steps below to create the load balancer:

1. Go to https://us-east-1.console.aws.amazon.com/ec2/home
2. Click "Target Groups"
3. Click "Create target group"
4. Type "instance1" in the "Target group name" field
5. Change the Port to "8000"
6. Select VPC and choose your VPC
7. Click "Create"
8. Click "Override"
9. Change the number field to "8000"
10. Click "Next"
11. Select your first instance
12. Click "Include as pending below"
13. Click "Create target group"
14. Repeat steps 4-13 to create another target group for the second instance and name it "instance2"
15. Click "Load Balancers"
16. Click "Create load balancer"
17. Click "Create" Application Load Balancer
18. Type "ALB-east" in the "Load balancer name" field (if this is in the East Region)
19. Select your VPC and the 2 subnets your instances are in
20. Click "create a new security group"
21. Type "ALB-HTTP" in the "Security group name Info:" field
22. Type "ALB http traffic" in the "Description Info:" field
23. Click "Add rule"
24. Click "HTTP"
25. Click "Custom"
26. Click "Anywhere-IPv4"
27. Click "Create security group"

## Configure Load Balancer

1. Go back to the Application Load Balancer tab and refresh the SG section
2. Select the "ALB-HTTP" SG
3. Deselect the default SG
4. Click "Select a target group"
5. Select your "instance1" target group
6. Click "Create load balancer"
7. Click "View load balancer"
8. Once the status says "Active" test the ALB by copying the DNS name and going to the URL
9. After testing the ALB URL, go back to AWS and click "Listeners and rules"
10. Click the checkbox
11. Click "Manage rules"
12. Click "Edit rules"
13. Click the checkbox
14. Click "Actions"
15. Click "Edit rule"
16. Click "Add target group"
17. Click "Select a target group"
18. Select your "instance2"
19. Notice the weight of the traffic is 50/50
20. Click "Save changes"
21. Click "Load balancers"
22. Test out the ALB URL again. If you see your homepage, do the same for the second Region (or the west region).