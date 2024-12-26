## Template Submission Guidelines

1. Clone this repository:
   ```
   git clone <repo_url>
   cd <repo_name>
   ```

2. Navigate to the `templates/` folder:
   ```
   cd templates/
   ```

3. Create a new JSON template file following the example below:
   ```json
   {
      "key": "example_",
      "name": "Example ",
      "description": "Description of the resource",
      "actions": {
          "create": {},
          "read": {},
          "update": {},
          "delete": {}
      },
      "attributes": {
          "created_at": { "type": "time", "description": "Timestamp when the resource was created" }
      },
      "roles": {
          "admin": {
              "name": "admin",
              "permissions": ["create", "read", "update", "delete"],
              "description": "Administrator with full access to the resource"
          }
      },
      "relations": {
          "parent": {
              "subject_resource": "",
              "description": "Resource is a child of "
          }
      }
   }
   ```

4. Save the file with a meaningful name:
   ```
   templates/<your_resource_name>.json
   ```

5. Create a new feature branch for the submission:
   ```
   git checkout -b feature/add-<your_resource_name>-template
   ```

6. Commit and push the changes:
   ```
   git add templates/<your_resource_name>.json
   git commit -m "Add template for <your_resource_name>"
   git push origin feature/add-<your_resource_name>-template
   ```

7. Open a Merge Request (MR) in GitLab and include the following:
   - A description of the resource.
   - Any specific details or edge cases to review.
