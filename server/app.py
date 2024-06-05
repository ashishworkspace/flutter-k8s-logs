from kubernetes import client, config
from kubernetes.client.rest import ApiException
from flask import Flask, request, jsonify
from flask_cors import CORS

# Load Kubernetes configuration
config.load_kube_config(config_file="local.yml")

app = Flask(__name__)
CORS(app)

@app.route('/get_logs', methods=['GET'])
def get_pod_logs():
    try:
        # Get pod name and namespace from query parameters
        pod_name = request.args.get('pod_name')
        namespace = request.args.get('namespace')

        if not pod_name or not namespace:
            return jsonify({'error': 'Pod name and namespace are required.'}), 400

        v1 = client.CoreV1Api()
        logs = v1.read_namespaced_pod_log(name=pod_name, namespace=namespace)

        # Split logs into lines
        log_lines = logs.split('\n')

        return jsonify(log_lines), 200
    except ApiException as e:
        print(f"Exception when calling CoreV1Api->read_namespaced_pod_log: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
