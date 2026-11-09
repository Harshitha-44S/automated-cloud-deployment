
import pytest
from app.app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.test_client() as client:
        yield client


# Unit Test 1: Check health endpoint
def test_health_endpoint(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"status": "healthy"}


# Integration Test 1: Check homepage
def test_homepage(client):
    response = client.get("/")

    assert response.status_code == 200
    assert b"<html" in response.data.lower()


# Integration Test 2: Check invalid route
def test_invalid_route(client):
    response = client.get("/invalid")

    assert response.status_code == 404
