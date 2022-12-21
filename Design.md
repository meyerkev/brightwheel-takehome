# Kevin Meyer's Brightwheel interview takehome

## Constraints:

There are 3 environments: Dev, Staging, Production

Consider the implementation for the following teams:
- Frontend Engineering - Requires access to CloudFront
- Backend Engineering - Requires access to EKS
- Data Engineering - Requires access to Redshift
- Site Reliability Engineering - Administrators

## Open Questions:
1. How do we distinguish between prod/staging/dev resources?  
   * Ideally, via separate accounts.  
   * else via tagging + copying the AWS permissions into custom policies that only work on tagged objects
   * Alternatively, dial it back, and convert the iam module into a metric instead

## Assumptions: 
* I'm not yet making Read vs. read-write distinctions
* For simplicities sake, when you say "EKS", I assume EKS:*
   * In practice, this would be wildly fractal
   * Though also in practice, quite a lot of the EKS roles would be handled as EKS permissions with IAM Role -> EKS User mappings
* We have one singular account instead of a Users account + 3 deployment accounts, which is what I did at Compass for a bunch of reasons.  
   * Among other reasons, I need to test this in my personal AWS account and thankfully AWS IAM limits to free.
   * On that note, this is a very well-designed interview actually.  I'm spending a couple hundred dollars on other takehomes.  Thank you.
* The point of staging is to test production changes, so it should be as aligned with Production as possible
* Features are built in dev, validated in staging, and presented to customers in prod.  

## Definitions: 

**Everything:** is distinct from Admin where Admin is Admin and Everything has access to Cloudfront, EKS, and Redshift

This should be considered distinct from Admin privileges because someone somewhere is going to run their personal website on
this at enough scale (At Compass, it was 175 engineers.  Hi Leon) and I really don't want them deleting the Cloudtrail Logs,
but I want to unblock development.  

So if your frontend change requires an EKS change, make it work, show it works, and we'll get OWNERS approval on the PR, instead
of spending multiple months in the bureaucracy when you're not even sure it'll work or _exactly_ what you need.  Bias Towards Action.

**Emergent:** I am aware there would be changes, and I could not tell you at this stage what they would be and how I would have to respond to them.
But they would exist and I would have to respond to them when they happened.  

## Implementation:

### At the account level: 

4 groups to start: 

* Frontend Engineering
* Backend Engineering
* Data Engineering
* SRE
    * Has godlike admin powers by way of group membership
* "Devs" so I can assign all Devs to something very trivially.  

### Prod:

Production needs 4 roles. 

SRE -> Admin 
Frontend -> Cloudfront:*
Backend -> Cloudfront:*
Data -> Redshift:*

### Staging

Is a copy of Prod as discussed

### Dev: 

Is a copy of Prod

**If/when we go multi-account**

We can't do this sanely in a single-account setup because giving people admin powers means either spending
hours building a custom policy for everything and setting up an environment-level tagging system.

I'm going to make a choice in this design and the choice is that everyone needs to have access to everything listed in Dev.
Ideally as their IAM user, but for RBAC reasons, this can't happen.  For speed reasons.  Unblock development.
Don't make me sign into SSO at 3AM.  If you destroy something important, this is why we have IAC.  Terraform apply.
If that doesn't work, we learned something today in a very cheap way and we know what we're fixing tomorrow.

Bias Towards Action when that action is cheap.  And always create a place to have error cheaply. Because getting logged out of SSO 4 times a day because your IT team set the login to 4 hours gets old fast.  

So there are two Groups with separate dev creds for every IAM Account.  

1. Dev-Everything -> Has access to Everything.  
2. Dev-Admin -> Has access as godlike powers 

## Future todo's: 

0. Figure out a better way to distinguish between environments (Tagging?)
1. This would get fractal very fast.  In ways that would be emergent.  I mentioned RO vs. RW, but that can just keep going.  
2. Related to that, this would depend on your oncall structure, but RO unless oncall in Prod would be another good one.  
3. There is a speed cost to this, but at large enough companies, prod access needs 2FA on SSO on the assumption that one 
   of your 50,000 employees is having a bad day and wants to rip down Prod.  Or you have a spy problem like, without loss of generality, Twitter.    
4. But also things like "Do Junior Devs have the power to delete the Redshift cluster EVEN IF they're primary data oncall?"
5. Don't do a local backend, put it up in S3 and do workspaces per environment
6. This would almost certainly be part of a larger design so build "Terraform/" as a directory 
7. Setup tf-docs and then use that to actually generate a proper README.md for both modules and main
8. The naive way to test Terraform is to turn it on and let observability do the work.  And in practice, that ends up being a good way when
   testing third-party APIs like AWS.  (If I enable staging, now what?)
9. Figure out a better way to distinguish between environments