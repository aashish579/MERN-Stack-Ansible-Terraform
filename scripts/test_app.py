#!/usr/bin/env python3
"""Read-only HTTP probes + one real create/read/list persistence test. No dependencies."""
import argparse
import datetime
import json
import urllib.error
import urllib.request
import sys


def request(url, data=None):
    method = "POST" if data is not None else "GET"
    payload = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=payload, method=method)
    req.add_header("Accept", "application/json")
    if payload is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=25) as response:
            body = response.read()
            try:
                parsed = json.loads(body)
            except (ValueError, UnicodeDecodeError):
                parsed = body.decode("utf-8", errors="replace")[:300]
            return response.status, parsed
    except urllib.error.HTTPError as e:
        excerpt = e.read(1200).decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} returned HTTP {e.code}; body: {excerpt}") from e


def check(condition, message):
    if not condition:
        raise RuntimeError(message)
    print(f"[PASS] {message}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", required=True, help="Example: http://54.123.45.67")
    parser.add_argument("--skip-post", action="store_true", help="Do not create another trip; just smoke-test GET endpoints")
    args = parser.parse_args()
    url = args.url.rstrip("/")
    print(f"Testing TravelMemory at {url}")
    code, home = request(url + "/")
    check(code == 200 and isinstance(home, str) and "<html" in home.lower(), "React application served over HTTP")
    code, health = request(url + "/health")
    check(code == 200, "API and MongoDB health endpoint HTTP 200")
    code, trips = request(url + "/trip")
    check(code == 200, "GET /trip HTTP 200")
    if args.skip_post:
        return 0
    suffix = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    demo = {
        "tripName": f"Terraform Ansible Demo {suffix}",
        "startDateOfJourney": "2026-11-01",
        "endDateOfJourney": "2026-11-05",
        "nameOfHotels": "Training Demo Hotel",
        "placesVisited": "Delhi, Agra, Jaipur",
        "totalCost": 12500,
        "tripType": "leisure",
        "experience": "An educational demonstration of creating and reading a TravelMemory record after Terraform and Ansible deployment.",
        "shortDescription": "AWS Terraform and Ansible persistent MongoDB verification record",
        "featured": False,
    }
    code, created = request(url + "/trip", demo)
    check(code == 201, "POST /trip HTTP 201: trip successfully created")
    trip = created.get("trip", {}) if isinstance(created, dict) else {}
    trip_id = trip.get("_id") or trip.get("id")
    check(bool(trip_id), "Create response includes the persisted MongoDB record ID")
    code, detail = request(url + "/trip/" + str(trip_id))
    check(code == 200, "GET /trip/:id HTTP 200: saved record fetched")
    code, listing = request(url + "/trip")
    if isinstance(listing, dict):
        listing = listing.get("trips", listing.get("data", []))
    ids = [str(x.get("_id", x.get("id", ""))) for x in listing if isinstance(x, dict)] if isinstance(listing, list) else []
    check(str(trip_id) in ids, "Saved trip is present after fresh GET /trip request")
    print(f"Record ID: {trip_id}")
    print(f"Record title: {demo['tripName']}")
    print("[PASS] End-to-end React/HTTP API/MongoDB persistence test completed")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        sys.exit(1)
