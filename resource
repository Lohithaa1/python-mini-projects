import logging
import asyncio
from services.permit_client import PermitClient
from models.resource_type_model import ResourceType

logger = logging.getLogger(__name__)

class ResourceManager:
    def __init__(self):
        self.permit_client = PermitClient()

    async def create_resource_with_roles_relations(self, resource_id: str, resource_details: dict):
        """
        Main function to create a resource along with roles and relations in Permit.io.
        """
        try:
            # Extract relations & roles before validation
            relations = resource_details.pop("relations", None)
            roles = resource_details.pop("roles", None)

            # Validate the resource data using ResourceType model
            resource = ResourceType(**resource_details)
            logger.info("Resource data validated successfully.")

            # Construct and create resource
            resource_payload = self.construct_resource_payload(resource_id, resource_details)
            created_resource = await self.permit_client.create_resource(resource_payload)

            if not created_resource:
                raise ValueError(f"Failed to create resource {resource_id}")

            # Process Relations if available
            if relations:
                await self.process_relations(resource_id, relations)

            # Process Roles if available
            if roles:
                await self.process_roles(resource_id, roles)

            logger.info(f"Resource {resource_id} created successfully with roles & relations.")
            return created_resource

        except Exception as e:
            logger.error(f"Failed to create resource {resource_id}: {e}")
            return None

    async def process_relations(self, resource_id: str, relations: dict):
        """
        Processes and creates relations for a given resource.
        """
        relations_payload = self.construct_relations_payload(resource_id, relations)
        for relation in relations_payload:
            try:
                await self.permit_client.create_resource_relation(resource_id, relation)
                logger.info(f"Relation {relation['subject_resource']} → {relation['key']} created successfully.")
            except Exception as e:
                logger.error(f"Failed to create relation {relation['subject_resource']} for resource {resource_id}: {e}")

    async def process_roles(self, resource_id: str, roles: dict):
        """
        Processes and creates roles for a given resource.
        """
        roles_payload = self.construct_roles_payload(resource_id, roles)
        for role in roles_payload:
            try:
                await self.permit_client.create_resource_role(resource_id, role)
                logger.info(f"Role {role['key']} created successfully for resource {resource_id}.")
            except Exception as e:
                logger.error(f"Failed to create role {role['key']} for resource {resource_id}: {e}")

    def construct_resource_payload(self, resource_id: str, resource_details: dict) -> dict:
        """
        Constructs the payload for creating a resource in Permit.io.
        """
        return {
            "key": resource_id,  # Unique identifier for the resource
            "name": resource_details.get("name", ""),
            "description": resource_details.get("description", ""),
            "actions": resource_details.get("actions", {}),  # Dict of actions associated with the resource
        }

    def construct_roles_payload(self, resource_id: str, roles: dict) -> list:
        """
        Constructs the payload for roles, including role derivations.
        """
        return [
            {
                "key": role_key,
                "name": role_details.get("name", ""),
                "description": role_details.get("description", ""),
                "permissions": role_details.get("permissions", []),
                "granted_to": role_details.get("granted_to", {}),  # Role derivation details
            }
            for role_key, role_details in roles.items()
        ]

    def construct_relations_payload(self, resource_id: str, relations: dict) -> list:
        """
        Constructs the payload for resource relations.
        """
        return [
            {
                "key": relation_key,
                "description": relation_details.get("description", ""),
                "subject_resource": relation_details.get("subject_resource", ""),
            }
            for relation_key, relation_details in relations.items()
        ]
